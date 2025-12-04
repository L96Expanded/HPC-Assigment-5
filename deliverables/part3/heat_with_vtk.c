#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NX 500
#define NY 500
#define MAX_ITER 1000
#define TOLERANCE 1e-6

void write_vtk_file(const char *filename, double u[NX][NY]) {
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
    fprintf(fp, "DIMENSIONS %d %d 1\n", NX, NY);
    fprintf(fp, "ORIGIN 0 0 0\n");
    fprintf(fp, "SPACING 1 1 1\n");
    fprintf(fp, "POINT_DATA %d\n", NX * NY);
    fprintf(fp, "SCALARS temperature float 1\n");
    fprintf(fp, "LOOKUP_TABLE default\n");

    // Write temperature data
    for (int j = 0; j < NY; j++) {
        for (int i = 0; i < NX; i++) {
            fprintf(fp, "%f\n", u[i][j]);
        }
    }

    fclose(fp);
    printf("VTK file written to: %s\n", filename);
}

int main() {
    double u[NX][NY], u_new[NX][NY];
    int i, j, iter;
    double diff, max_diff;

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
            printf("Converged after %d iterations.\n", iter);
            break;
        }
    }

    // Write results to VTK file
    write_vtk_file("heat_output.vtk", u);

    return 0;
}
