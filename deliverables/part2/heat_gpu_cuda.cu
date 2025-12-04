#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define NX 500
#define NY 500
#define MAX_ITER 1000
#define TOLERANCE 1e-6
#define BLOCK_SIZE 16

// CUDA kernel for heat equation update
__global__ void heat_kernel(double *u, double *u_new, int nx, int ny, double *max_diff_device) {
    int i = blockIdx.x * blockDim.x + threadIdx.x + 1;
    int j = blockIdx.y * blockDim.y + threadIdx.y + 1;
    
    __shared__ double s_max_diff[BLOCK_SIZE * BLOCK_SIZE];
    int tid = threadIdx.y * blockDim.x + threadIdx.x;
    s_max_diff[tid] = 0.0;
    
    if (i < nx - 1 && j < ny - 1) {
        int idx = i * ny + j;
        u_new[idx] = 0.25 * (u[(i+1)*ny + j] + u[(i-1)*ny + j] +
                             u[i*ny + j+1] + u[i*ny + j-1]);
        double diff = fabs(u_new[idx] - u[idx]);
        s_max_diff[tid] = diff;
    }
    
    __syncthreads();
    
    // Reduction within block
    for (int s = blockDim.x * blockDim.y / 2; s > 0; s >>= 1) {
        if (tid < s) {
            s_max_diff[tid] = fmax(s_max_diff[tid], s_max_diff[tid + s]);
        }
        __syncthreads();
    }
    
    if (tid == 0) {
        atomicMax((unsigned long long *)max_diff_device, 
                  __double_as_longlong(s_max_diff[0]));
    }
}

// CUDA kernel for copying u_new to u
__global__ void copy_kernel(double *u, double *u_new, int nx, int ny) {
    int i = blockIdx.x * blockDim.x + threadIdx.x + 1;
    int j = blockIdx.y * blockDim.y + threadIdx.y + 1;
    
    if (i < nx - 1 && j < ny - 1) {
        u[i * ny + j] = u_new[i * ny + j];
    }
}

// Helper function for atomicMax with double
__device__ double atomicMaxDouble(double* address, double val) {
    unsigned long long* address_as_ull = (unsigned long long*)address;
    unsigned long long old = *address_as_ull, assumed;
    do {
        assumed = old;
        old = atomicCAS(address_as_ull, assumed,
                        __double_as_longlong(fmax(val, __longlong_as_double(assumed))));
    } while (assumed != old);
    return __longlong_as_double(old);
}

int main() {
    double *u, *u_new;
    double *d_u, *d_u_new, *d_max_diff;
    int i, j, iter;
    double max_diff, h_max_diff;
    cudaEvent_t start, stop;
    float elapsed_time;

    // Allocate host memory
    u = (double *)malloc(NX * NY * sizeof(double));
    u_new = (double *)malloc(NX * NY * sizeof(double));

    // Initialize grid
    for (i = 0; i < NX; i++) {
        for (j = 0; j < NY; j++) {
            int idx = i * NY + j;
            u[idx] = 0.0;
            if (i == 0 || i == NX - 1 || j == 0 || j == NY - 1) {
                u[idx] = 100.0;
            }
        }
    }

    // Allocate device memory
    cudaMalloc(&d_u, NX * NY * sizeof(double));
    cudaMalloc(&d_u_new, NX * NY * sizeof(double));
    cudaMalloc(&d_max_diff, sizeof(double));

    // Copy data to device
    cudaMemcpy(d_u, u, NX * NY * sizeof(double), cudaMemcpyHostToDevice);

    // Set up grid and block dimensions
    dim3 blockDim(BLOCK_SIZE, BLOCK_SIZE);
    dim3 gridDim((NX - 2 + BLOCK_SIZE - 1) / BLOCK_SIZE,
                 (NY - 2 + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // Create CUDA events for timing
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    // Iterative solver
    for (iter = 0; iter < MAX_ITER; iter++) {
        // Reset max_diff on device
        h_max_diff = 0.0;
        cudaMemcpy(d_max_diff, &h_max_diff, sizeof(double), cudaMemcpyHostToDevice);

        // Launch kernel
        heat_kernel<<<gridDim, blockDim>>>(d_u, d_u_new, NX, NY, d_max_diff);
        cudaDeviceSynchronize();

        // Copy u_new to u
        copy_kernel<<<gridDim, blockDim>>>(d_u, d_u_new, NX, NY);
        cudaDeviceSynchronize();

        // Copy max_diff back to host
        cudaMemcpy(&max_diff, d_max_diff, sizeof(double), cudaMemcpyDeviceToHost);

        // Check for convergence
        if (max_diff < TOLERANCE) {
            printf("CUDA: Converged after %d iterations.\n", iter);
            break;
        }
    }

    // Stop timing
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed_time, start, stop);
    printf("CUDA execution time: %f seconds\n", elapsed_time / 1000.0);

    // Copy result back to host
    cudaMemcpy(u, d_u, NX * NY * sizeof(double), cudaMemcpyDeviceToHost);

    // Free memory
    free(u);
    free(u_new);
    cudaFree(d_u);
    cudaFree(d_u_new);
    cudaFree(d_max_diff);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
