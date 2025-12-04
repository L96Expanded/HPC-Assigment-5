#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>
#include <openacc.h>

#define NX 500
#define NY 500
#define MAX_ITER 1000
#define TOLERANCE 1e-6

int main(int argc, char **argv) {
    double *u, *u_new;
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
    local_ny = (NY - 2) / size;
    start_y = rank * local_ny + 1;
    end_y = (rank == size - 1) ? (NY - 1) : (start_y + local_ny);

    // Allocate local arrays with ghost rows (flattened for GPU)
    int actual_ny = end_y - start_y + 2;
    u = (double *)malloc(NX * actual_ny * sizeof(double));
    u_new = (double *)malloc(NX * actual_ny * sizeof(double));

    // Initialize local grid
    #pragma omp parallel for private(i, j)
    for (i = 0; i < NX; i++) {
        for (j = 0; j < actual_ny; j++) {
            int global_j = start_y + j - 1;
            int idx = i * actual_ny + j;
            u[idx] = 0.0;
            // Boundary conditions
            if (i == 0 || i == NX - 1 || global_j == 0 || global_j == NY - 1) {
                u[idx] = 100.0;
            }
        }
    }

    // Copy data to GPU
    #pragma acc enter data copyin(u[0:NX*actual_ny], u_new[0:NX*actual_ny])

    // Iterative solver
    for (iter = 0; iter < MAX_ITER; iter++) {
        // Copy ghost rows back to CPU for MPI communication
        #pragma acc update host(u[0:NX*actual_ny])

        // Exchange ghost rows
        if (rank > 0) {
            for (i = 0; i < NX; i++) {
                MPI_Send(&u[i * actual_ny + 1], 1, MPI_DOUBLE, rank - 1, 0, MPI_COMM_WORLD);
                MPI_Recv(&u[i * actual_ny], 1, MPI_DOUBLE, rank - 1, 1, MPI_COMM_WORLD, &status);
            }
        }
        if (rank < size - 1) {
            int last_row = actual_ny - 2;
            for (i = 0; i < NX; i++) {
                MPI_Recv(&u[i * actual_ny + actual_ny - 1], 1, MPI_DOUBLE, rank + 1, 0, MPI_COMM_WORLD, &status);
                MPI_Send(&u[i * actual_ny + last_row], 1, MPI_DOUBLE, rank + 1, 1, MPI_COMM_WORLD);
            }
        }

        // Copy updated ghost rows back to GPU
        #pragma acc update device(u[0:NX*actual_ny])

        max_diff = 0.0;

        // Compute new values on GPU
        #pragma acc parallel loop collapse(2) reduction(max:max_diff) present(u, u_new)
        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < actual_ny - 1; j++) {
                int idx = i * actual_ny + j;
                u_new[idx] = 0.25 * (u[(i+1) * actual_ny + j] + u[(i-1) * actual_ny + j]
                                    + u[i * actual_ny + j + 1] + u[i * actual_ny + j - 1]);
                diff = fabs(u_new[idx] - u[idx]);
                if (diff > max_diff) {
                    max_diff = diff;
                }
            }
        }

        // Update u on GPU
        #pragma acc parallel loop collapse(2) present(u, u_new)
        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < actual_ny - 1; j++) {
                int idx = i * actual_ny + j;
                u[idx] = u_new[idx];
            }
        }

        // Global reduction to find maximum difference
        MPI_Allreduce(&max_diff, &global_max_diff, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);

        // Check for convergence
        if (global_max_diff < TOLERANCE) {
            if (rank == 0) {
                printf("GPU: Converged after %d iterations.\n", iter);
            }
            break;
        }
    }

    // Copy data back from GPU
    #pragma acc exit data copyout(u[0:NX*actual_ny]) delete(u_new)

    // End timing
    end_time = MPI_Wtime();
    if (rank == 0) {
        printf("GPU-accelerated execution time: %f seconds\n", end_time - start_time);
    }

    // Free memory
    free(u);
    free(u_new);

    MPI_Finalize();
    return 0;
}
