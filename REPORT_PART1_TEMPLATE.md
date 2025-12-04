# HPC Assignment Part 1 Report Template
# 2D Heat Equation Solver - MPI and OpenMP Parallelization

## Student Information
- **Name:** [Your Name]
- **Student ID:** [Your ID]
- **Date:** [Submission Date]

---

## 1. Introduction

This report describes the parallelization of a 2D heat equation solver using MPI and OpenMP. The original serial code solves the heat equation on a 500×500 grid using the finite difference method with iterative convergence.

---

## 2. Parallelization Strategy

### 2.1 MPI Parallelization

**Domain Decomposition:**
- Implemented row-wise (horizontal) decomposition of the 2D grid
- Each MPI process handles a subset of rows: `local_ny = (NY - 2) / size`
- Ghost rows added at boundaries for inter-process communication

**Communication Pattern:**
- Used blocking MPI_Send/MPI_Recv for ghost row exchange
- Each process communicates with rank-1 (above) and rank+1 (below)
- Global reduction (MPI_Allreduce) used to find maximum difference across all processes

**Key Implementation Details:**
```c
// Row exchange with neighbors
if (rank > 0) {
    MPI_Send(&u[i][1], 1, MPI_DOUBLE, rank - 1, 0, MPI_COMM_WORLD);
    MPI_Recv(&u[i][0], 1, MPI_DOUBLE, rank - 1, 1, MPI_COMM_WORLD, &status);
}

// Global convergence check
MPI_Allreduce(&max_diff, &global_max_diff, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
```

### 2.2 OpenMP Parallelization

**Thread-Level Parallelism:**
- Parallel loops for grid point updates within each MPI process
- Reduction clause for finding local maximum difference
- Collapse(2) directive for better load balancing on nested loops

**Implementation:**
```c
#pragma omp parallel for private(i, j, diff) reduction(max:max_diff) collapse(2)
for (i = 1; i < NX - 1; i++) {
    for (j = 1; j < actual_ny - 1; j++) {
        u_new[i][j] = 0.25 * (u[i+1][j] + u[i-1][j] + u[i][j+1] + u[i][j-1]);
        diff = fabs(u_new[i][j] - u[i][j]);
        if (diff > max_diff) max_diff = diff;
    }
}
```

---

## 3. Challenges and Solutions

### Challenge 1: Ghost Row Communication
**Problem:** Initial implementation had incorrect indexing for ghost rows, causing convergence issues.

**Solution:** Added explicit ghost row indices (0 and actual_ny-1) and verified boundary conditions are maintained after communication.

### Challenge 2: Race Conditions in OpenMP
**Problem:** Shared variable access caused incorrect max_diff calculations.

**Solution:** Used reduction(max:max_diff) clause and ensured proper private/shared variable declarations.

### Challenge 3: Load Imbalance
**Problem:** Last MPI process handled extra rows when (NY-2) not evenly divisible by size.

**Solution:** Adjusted end_y calculation for the last process:
```c
end_y = (rank == size - 1) ? (NY - 1) : (start_y + local_ny);
```

---

## 4. Performance Analysis

### 4.1 Execution Times

| Configuration | Processes | Threads/Process | Time (seconds) | Speedup | Efficiency |
|--------------|-----------|-----------------|----------------|---------|------------|
| Serial       | 1         | 1               | [Your data]    | 1.00    | 100%       |
| Parallel     | 4         | 1               | [Your data]    | [calc]  | [calc]     |
| Parallel     | 8         | 1               | [Your data]    | [calc]  | [calc]     |
| Parallel     | 12        | 1               | [Your data]    | [calc]  | [calc]     |
| Parallel     | 4         | 2               | [Your data]    | [calc]  | [calc]     |
| Parallel     | 12        | 2               | [Your data]    | [calc]  | [calc]     |

**Calculations:**
- Speedup = T_serial / T_parallel
- Efficiency = Speedup / (Processes × Threads)

### 4.2 Scalability Analysis

[Insert graph showing speedup vs. number of processors]

**Observations:**
- [Describe scaling behavior]
- [Note any bottlenecks or limitations]
- [Comment on strong vs. weak scaling]

### 4.3 Convergence Verification

**Convergence Check:**
- Serial version converged after: [X] iterations
- Parallel version converged after: [Y] iterations
- Results match: [Yes/No]

---

## 5. Cluster Execution

### SLURM Configuration
```bash
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
```

**Total Resources:**
- 3 nodes × 4 tasks/node = 12 MPI processes
- 2 OpenMP threads per process = 24 total threads

**Job Output:**
[Paste relevant output from heat_parallel.out]

---

## 6. Conclusion

### Key Achievements
- Successfully parallelized 2D heat solver using MPI and OpenMP
- Achieved [X]x speedup with 12 MPI processes
- Verified correctness through convergence comparison

### Lessons Learned
- [Your insights about parallel programming]
- [What worked well and what didn't]
- [Future optimization opportunities]

### Future Improvements
- Use non-blocking MPI (Isend/Irecv) to overlap communication and computation
- Implement 2D Cartesian topology for better neighbor management
- Optimize memory layout for better cache performance

---

## 7. References

1. MPI Documentation: https://www.open-mpi.org/doc/
2. OpenMP Specification: https://www.openmp.org/
3. Course materials and lecture notes
4. SLURM Documentation: https://slurm.schedmd.com/

---

## Appendix A: Complete Source Code

[Attach or reference heat_parallel.c]

## Appendix B: SLURM Scripts

[Attach heat_job.slurm]

## Appendix C: Compilation Commands

```bash
module load gcc/9.3.0
module load openmpi/4.0.3
mpicc -fopenmp -O3 -o heat_parallel heat_parallel.c -lm
```
