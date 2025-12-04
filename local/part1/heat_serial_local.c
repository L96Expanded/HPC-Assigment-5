#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define NX 500
#define NY 500
#define MAX_ITER 1000
#define TOLERANCE 1e-6

int main() {
    double u[NX][NY], u_new[NX][NY];
    int i, j, iter;
    double diff, max_diff;
    clock_t start, end;
    double cpu_time_used;

    printf("=== 2D Heat Equation Solver - Serial Version ===\n");
    printf("Grid size: %d x %d\n", NX, NY);
    printf("Max iterations: %d\n", MAX_ITER);
    printf("Tolerance: %e\n\n", TOLERANCE);

    // Start timing
    start = clock();

    // Initialize the grid
    for (i = 0; i < NX; i++) {
        for (j = 0; j < NY; j++) {
            u[i][j] = 0.0;
            if (i == 0 || i == NX - 1 || j == 0 || j == NY - 1) {
                u[i][j] = 100.0; // Boundary conditions
            }
        }
    }

    // Iterative solver
    for (iter = 0; iter < MAX_ITER; iter++) {
        max_diff = 0.0;

        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < NY - 1; j++) {
                u_new[i][j] = 0.25 * (u[i+1][j] + u[i-1][j]
                                     + u[i][j+1] + u[i][j-1]);
                diff = fabs(u_new[i][j] - u[i][j]);
                if (diff > max_diff) {
                    max_diff = diff;
                }
            }
        }

        // Update u
        for (i = 1; i < NX - 1; i++) {
            for (j = 1; j < NY - 1; j++) {
                u[i][j] = u_new[i][j];
            }
        }

        // Check for convergence
        if (max_diff < TOLERANCE) {
            printf("Converged after %d iterations.\n", iter + 1);
            break;
        }
    }

    if (iter == MAX_ITER) {
        printf("Maximum iterations (%d) reached without convergence.\n", MAX_ITER);
    }

    // End timing
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    
    printf("\n=== Performance Results ===\n");
    printf("Serial execution time: %.4f seconds\n", cpu_time_used);
    printf("Final max difference: %e\n", max_diff);
    
    // Calculate average temperature (excluding boundaries)
    double avg_temp = 0.0;
    int count = 0;
    for (i = 1; i < NX - 1; i++) {
        for (j = 1; j < NY - 1; j++) {
            avg_temp += u[i][j];
            count++;
        }
    }
    avg_temp /= count;
    printf("Average interior temperature: %.4f\n", avg_temp);

    return 0;
}
