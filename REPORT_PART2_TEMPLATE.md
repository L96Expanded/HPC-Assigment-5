# HPC Assignment Part 2 Report Template
# GPU Acceleration using OpenACC/CUDA

## Student Information
- **Name:** [Your Name]
- **Student ID:** [Your ID]
- **Date:** [Submission Date]
- **GPU Method:** [OpenACC / CUDA]

---

## 1. Introduction

This report describes the GPU acceleration implementation for the 2D heat equation solver. Building upon the MPI+OpenMP parallelization from Part 1, this work adds GPU computing capabilities to further improve performance.

**Selected Approach:** [OpenACC / CUDA]

**Justification:** [Why you chose this approach]

---

## 2. GPU Implementation

### 2.1 OpenACC Implementation (if applicable)

**Data Movement Strategy:**
```c
// Copy data to GPU at start
#pragma acc enter data copyin(u[0:NX*actual_ny], u_new[0:NX*actual_ny])

// Keep data on GPU during iterations
#pragma acc parallel loop collapse(2) reduction(max:max_diff) present(u, u_new)
for (i = 1; i < NX - 1; i++) {
    for (j = 1; j < actual_ny - 1; j++) {
        // Computation
    }
}

// Copy results back at end
#pragma acc exit data copyout(u[0:NX*actual_ny]) delete(u_new)
```

**Key Directives Used:**
- `#pragma acc enter data` - Initial data transfer to GPU
- `#pragma acc parallel loop` - Parallel execution on GPU
- `#pragma acc update` - Selective data synchronization for MPI
- `collapse(2)` - 2D parallelization
- `reduction(max:max_diff)` - Finding maximum across threads

### 2.2 CUDA Implementation (if applicable)

**Kernel Design:**
```cuda
__global__ void heat_kernel(double *u, double *u_new, int nx, int ny, double *max_diff_device) {
    int i = blockIdx.x * blockDim.x + threadIdx.x + 1;
    int j = blockIdx.y * blockDim.y + threadIdx.y + 1;
    
    if (i < nx - 1 && j < ny - 1) {
        int idx = i * ny + j;
        u_new[idx] = 0.25 * (u[(i+1)*ny + j] + u[(i-1)*ny + j] +
                             u[i*ny + j+1] + u[i*ny + j-1]);
        // Reduction logic
    }
}
```

**Grid/Block Configuration:**
- Block size: 16×16 threads (256 threads per block)
- Grid size: `((NX-2)/16) × ((NY-2)/16)` blocks
- Total threads: Covers all interior grid points

**Memory Management:**
- Used `cudaMalloc` for device memory allocation
- `cudaMemcpy` for host-device transfers
- `cudaFree` for cleanup

**Reduction Strategy:**
- Shared memory reduction within blocks
- Atomic operations for global maximum

---

## 3. Challenges and Solutions

### Challenge 1: Data Transfer Overhead
**Problem:** Initial implementation transferred data every iteration, causing significant overhead.

**Solution:** [Describe your solution - e.g., kept data on GPU, only transferring ghost rows for MPI]

### Challenge 2: Reduction on GPU
**Problem:** Finding global maximum difference required careful reduction implementation.

**Solution:** [Your approach - OpenACC: reduction clause, CUDA: shared memory + atomics]

### Challenge 3: GPU Resource Availability
**Problem:** [If applicable - limited GPU nodes on cluster]

**Solution:** [Used Google Colab / Waited for GPU nodes / Other]

### Challenge 4: [Your challenge]
**Problem:** [Description]

**Solution:** [Your solution]

---

## 4. Performance Analysis

### 4.1 Execution Times

| Implementation | Platform | Time (seconds) | Speedup vs Serial | Speedup vs CPU Parallel |
|---------------|----------|----------------|-------------------|------------------------|
| Serial        | CPU      | [Your data]    | 1.00              | -                      |
| MPI+OpenMP    | CPU      | [Your data]    | [calc]            | 1.00                   |
| GPU (OpenACC) | GPU      | [Your data]    | [calc]            | [calc]                 |
| GPU (CUDA)    | GPU      | [Your data]    | [calc]            | [calc]                 |

**Platform Details:**
- CPU: [Cluster node specs or local machine]
- GPU: [Tesla/K80/T4/etc. from cluster or Colab]
- CUDA Version: [version]

### 4.2 Performance Breakdown

**Time Analysis:**
- Data transfer (CPU↔GPU): [X] seconds ([Y]%)
- Computation on GPU: [X] seconds ([Y]%)
- MPI communication: [X] seconds ([Y]%)

### 4.3 Speedup Analysis

[Insert graph comparing execution times]

**Key Observations:**
- GPU provides [X]x speedup over CPU parallel version
- Overall speedup from serial: [Y]x
- [Discuss whether speedup meets expectations]

### 4.4 GPU Utilization

**Occupancy:** [If measured - percentage of GPU utilization]

**Memory Bandwidth:** [If measured]

**Optimization Opportunities:**
- [List potential improvements]

---

## 5. Execution Environment

### 5.1 Cluster Execution (if applicable)

**SLURM Configuration:**
```bash
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
```

**Modules Loaded:**
```bash
module load cuda/11.0
module load gcc/9.3.0
```

### 5.2 Google Colab Execution (if applicable)

**Setup:**
1. Changed runtime to GPU (Runtime → Change runtime type)
2. Verified GPU: `!nvidia-smi`
3. Compiled and ran code

**Colab GPU:** [T4 / K80 / other]

---

## 6. Correctness Verification

### Convergence Check
- GPU version converged after: [X] iterations
- CPU parallel version converged after: [Y] iterations
- Match: [Yes/No - explain any differences]

### Result Validation
[Describe how you verified results are correct]

---

## 7. Comparison: OpenACC vs CUDA (if you tried both)

| Aspect | OpenACC | CUDA |
|--------|---------|------|
| Ease of Implementation | [Your assessment] | [Your assessment] |
| Performance | [Your data] | [Your data] |
| Code Portability | [Your assessment] | [Your assessment] |
| Control/Flexibility | [Your assessment] | [Your assessment] |

**Recommendation:** [Which approach you prefer and why]

---

## 8. Conclusion

### Key Achievements
- Successfully implemented GPU acceleration
- Achieved [X]x speedup over CPU parallel version
- Total speedup from serial: [Y]x

### Lessons Learned
- [Your insights about GPU programming]
- [Challenges of heterogeneous computing]
- [When GPU acceleration is beneficial]

### Performance Summary
```
Serial:        [X] seconds
CPU Parallel:  [Y] seconds  ([speedup]x)
GPU:           [Z] seconds  ([speedup]x from serial)
```

### Future Improvements
- Multi-GPU implementation
- Further optimization of memory transfers
- Overlapping computation and communication
- Tuning block/grid dimensions

---

## 9. References

1. CUDA C Programming Guide: https://docs.nvidia.com/cuda/
2. OpenACC Best Practices: https://www.openacc.org/
3. NVIDIA Developer Documentation
4. Course materials and lecture notes

---

## Appendix A: Complete Source Code

[Attach or reference heat_gpu_openacc.c or heat_gpu_cuda.cu]

## Appendix B: SLURM Script

[Attach heat_gpu_job.slurm if applicable]

## Appendix C: Compilation Commands

**OpenACC:**
```bash
module load cuda/11.0
mpicc -fopenmp -fopenacc -o heat_gpu_openacc heat_gpu_openacc.c -lm
```

**CUDA:**
```bash
module load cuda/11.0
nvcc -O3 -o heat_gpu_cuda heat_gpu_cuda.cu -lm
```

## Appendix D: Profiling Output (if available)

[Include nvprof or nsight output if you profiled the code]
