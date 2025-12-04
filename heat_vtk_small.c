#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NX 200
#define NY 200
#define MAX_ITER 1000
#define TOLERANCE 1e-6

void write_vtk_file(const char *filename, double **u, int nx, int ny) {
    FILE *fp = fopen(filename, "w");
    if (fp == NULL) {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
        return;
    }

    // Write VTK header
    fprintf(fp, "# vtk DataFile Version 2.0\n");
    fprintf(fp, "2D Heat Equation Data\n");
    fprintf(fp, "ASCII\n");
    fprintf(fp, "DATASET STRUCTURED_POINTS\n");
    fprintf(fp, "DIMENSIONS %d %d 1\n", nx, ny);
    fprintf(fp, "ORIGIN 0 0 0\n");
    fprintf(fp, "SPACING 1 1 1\n");
    fprintf(fp, "POINT_DATA %d\n", nx * ny);
    fprintf(fp, "SCALARS temperature float 1\n");
    fprintf(fp, "LOOKUP_TABLE default\n");

    // Write temperature data
    for (int j = 0; j < ny; j++) {
        for (int i = 0; i < nx; i++) {
            fprintf(fp, "%f\n", u[i][j]);
        }
    }

    fclose(fp);
    printf("VTK file written to: %s\n", filename);
}

int main() {
    int i, j, iter;
    double diff, max_diff;

    // Dynamically allocate arrays to avoid stack overflow
    double **u = (double **)malloc(NX * sizeof(double *));
    double **u_new = (double **)malloc(NX * sizeof(double *));
    for (i = 0; i < NX; i++) {
        u[i] = (double *)malloc(NY * sizeof(double));
        u_new[i] = (double *)malloc(NY * sizeof(double));
    }

    printf("Starting heat simulation with grid size %dx%d\n", NX, NY);

    // Initialize the grid
    for (i = 0; i < NX; i++) {
        for (j = 0; j < NY; j++) {
            u[i][j] = 0.0;
            if (i == 0 || i == NX - 1 || j == 0 || j == NY - 1) {
                u[i][j] = 100.0; // Boundary conditions
            }
        }
    }

    printf("Grid initialized. Running solver...\n");

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

        // Print progress every 100 iterations
        if (iter % 100 == 0) {
            printf("Iteration %d, max_diff = %e\n", iter, max_diff);
        }

        // Check for convergence
        if (max_diff < TOLERANCE) {
            printf("Converged after %d iterations.\n", iter);
            break;
        }
    }

    if (iter == MAX_ITER) {
        printf("Reached maximum iterations (%d) without full convergence.\n", MAX_ITER);
    }

    // Write results to VTK file
    printf("Writing VTK output...\n");
    write_vtk_file("heat_output.vtk", u, NX, NY);

    // Free memory
    for (i = 0; i < NX; i++) {
        free(u[i]);
        free(u_new[i]);
    }
    free(u);
    free(u_new);

    printf("Done!\n");
    return 0;
}
