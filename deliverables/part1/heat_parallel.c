#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>

#define NX 500
#define NY 500
#define MAX_ITER 1000
#define TOLERANCE 1e-6

int main(int argc, char **argv) {
    double **u, **u_new;
    int i, j, iter;
    double diff, max_diff, global_max_diff;
    int rank, size;
    int local_ny, start_y, end_y;
    MPI_Status status;
    double start_time, end_time;

    // Initialize MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Start timing
    start_time = MPI_Wtime();

    // Divide the domain among processes (row-wise decomposition)
    local_ny = (NY - 2) / size;  // Interior points only
    start_y = rank * local_ny + 1;
    end_y = (rank == size - 1) ? (NY - 1) : (start_y + local_ny);

    // Allocate local arrays with ghost rows
    int actual_ny = end_y - start_y + 2;  // +2 for ghost rows
    u = (double **)malloc(NX * sizeof(double *));
    u_new = (double **)malloc(NX * sizeof(double *));
    for (i = 0; i < NX; i++) {
        u[i] = (double *)malloc(actual_ny * sizeof(double));
        u_new[i] = (double *)malloc(actual_ny * sizeof(double));
    }

    // Initialize local grid
    #pragma omp parallel for private(i, j) collapse(2)
    for (i = 0; i < NX; i++) {
        for (j = 0; j < actual_ny; j++) {
            int global_j = start_y + j - 1;
            u[i][j] = 0.0;
            // Boundary conditions
            if (i == 0 || i == NX - 1 || global_j == 0 || global_j == NY - 1) {
                u[i][j] = 100.0;
            }
        }
    }

    // Iterative solver
    for (iter = 0; iter < MAX_ITER; iter++) {
        // Exchange ghost rows
        if (rank > 0) {
            // Send top row to rank-1, receive from rank-1
            for (i = 0; i < NX; i++) {
                MPI_Send(&u[i][1], 1, MPI_DOUBLE, rank - 1, 0, MPI_COMM_WORLD);
                MPI_Recv(&u[i][0], 1, MPI_DOUBLE, rank - 1, 1, MPI_COMM_WORLD, &status);
            }
        }
        if (rank < size - 1) {
            // Send bottom row to rank+1, receive from rank+1
            int last_row = actual_ny - 2;
            for (i = 0; i < NX; i++) {
                MPI_Recv(&u[i][actual_ny - 1], 1, MPI_DOUBLE, rank + 1, 0, MPI_COMM_WORLD, &status);
                MPI_Send(&u[i][last_row], 1, MPI_DOUBLE, rank + 1, 1, MPI_COMM_WORLD);
            }
        }

        max_diff = 0.0;

        // Compute new values using OpenMP
        #pragma omp parallel for private(i, j, diff) reduction(max:max_diff) collapse(2)
        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < actual_ny - 1; j++) {
                u_new[i][j] = 0.25 * (u[i+1][j] + u[i-1][j]
                                     + u[i][j+1] + u[i][j-1]);
                diff = fabs(u_new[i][j] - u[i][j]);
                if (diff > max_diff) {
                    max_diff = diff;
                }
            }
        }

        // Update u using OpenMP
        #pragma omp parallel for private(i, j) collapse(2)
        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < actual_ny - 1; j++) {
                u[i][j] = u_new[i][j];
            }
        }

        // Global reduction to find maximum difference
        MPI_Allreduce(&max_diff, &global_max_diff, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);

        // Check for convergence
        if (global_max_diff < TOLERANCE) {
            if (rank == 0) {
                printf("Converged after %d iterations.\n", iter);
            }
            break;
        }
    }

    // End timing
    end_time = MPI_Wtime();
    if (rank == 0) {
        printf("Parallel execution time: %f seconds\n", end_time - start_time);
    }

    // Free memory
    for (i = 0; i < NX; i++) {
        free(u[i]);
        free(u_new[i]);
    }
    free(u);
    free(u_new);

    MPI_Finalize();
    return 0;
}
