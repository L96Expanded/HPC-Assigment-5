# HPC Assignment: 2D Heat Equation Solver

## Overview

This project implements a parallel 2D heat equation solver using MPI, OpenMP, and GPU acceleration (OpenACC/CUDA). The assignment is structured in multiple parts with optional visualization using VTK.

## Project Structure

```
Assignment HPC Module 5/
├── heat_serial.c              # Serial implementation (baseline)
├── heat_parallel.c            # MPI + OpenMP parallel implementation
├── heat_gpu_openacc.c        # GPU-accelerated version using OpenACC
├── heat_gpu_cuda.cu          # GPU-accelerated version using CUDA
├── heat_with_vtk.c           # Serial version with VTK output
├── heat_job.slurm            # SLURM script for CPU parallel execution
├── heat_gpu_job.slurm        # SLURM script for GPU execution
├── visualize_heat.py         # VTK visualization script (desktop)
├── visualize_heat_colab.py   # Matplotlib visualization for Colab
├── Makefile                  # Build automation
└── README.md                 # This file
```

## Prerequisites

### On HPC Cluster
```bash
module load gcc/9.3.0
module load openmpi/4.0.3
module load cuda/11.0  # For GPU versions
```

### For Visualization (Local/Colab)
```bash
pip install vtk numpy matplotlib
```

## Part 1: MPI + OpenMP Parallelization

### Compilation

**Serial version:**
```bash
gcc -o heat_serial heat_serial.c -lm
```

**Parallel version (MPI + OpenMP):**
```bash
mpicc -fopenmp -o heat_parallel heat_parallel.c -lm
```

### Local Testing

**Serial:**
```bash
./heat_serial
```

**Parallel (example with 4 processes, 2 threads each):**
```bash
export OMP_NUM_THREADS=2
mpirun -np 4 ./heat_parallel
```

### Cluster Execution

1. Compile on the cluster:
```bash
ssh your_username@hpcie.labs.faculty.ie.edu
module load gcc/9.3.0
module load openmpi/4.0.3
mpicc -fopenmp -o heat_parallel heat_parallel.c -lm
```

2. Submit the job:
```bash
sbatch heat_job.slurm
```

3. Monitor the job:
```bash
squeue -u your_username
```

4. Check results:
```bash
cat heat_parallel.out
```

### Implementation Details

**MPI Parallelization:**
- Domain decomposition: Grid divided row-wise among MPI processes
- Ghost row exchange using MPI_Send/MPI_Recv for boundary communication
- Global reduction (MPI_Allreduce) to check convergence across all processes

**OpenMP Parallelization:**
- Parallel loops for grid updates within each MPI process
- Reduction clause for finding maximum difference
- Proper handling of shared/private variables

## Part 2: GPU Acceleration

### OpenACC Version

**Compilation:**
```bash
mpicc -fopenmp -fopenacc -o heat_gpu_openacc heat_gpu_openacc.c -lm
# Or with PGI/NVIDIA compiler:
pgcc -acc -ta=tesla -Minfo=accel -o heat_gpu_openacc heat_gpu_openacc.c -lm
```

**Execution:**
```bash
sbatch heat_gpu_job.slurm
```

### CUDA Version

**Compilation:**
```bash
nvcc -o heat_gpu_cuda heat_gpu_cuda.cu -lm
```

**Execution:**
```bash
./heat_gpu_cuda
# Or submit via SLURM:
sbatch heat_gpu_job.slurm
```

### Google Colab Alternative

If GPU nodes are unavailable on the cluster, use Google Colab:

1. Set runtime to GPU: `Runtime > Change runtime type > GPU`

2. Upload the CUDA file and compile:
```python
!nvcc -o heat_gpu_cuda heat_gpu_cuda.cu
!./heat_gpu_cuda
```

## Optional Bonus: VTK Visualization

### Generate VTK Output

**Compile with VTK output:**
```bash
gcc -o heat_with_vtk heat_with_vtk.c -lm
./heat_with_vtk
```

This generates `heat_output.vtk`.

### Visualization Methods

#### Method 1: Python VTK (Desktop)
```bash
pip install vtk
python visualize_heat.py heat_output.vtk
```

#### Method 2: Matplotlib (Colab-friendly)
```bash
pip install matplotlib numpy
python visualize_heat_colab.py
```

#### Method 3: ParaView (GUI)
1. Download ParaView from https://www.paraview.org/
2. Open `heat_output.vtk`
3. Apply filters and visualizations

### Colab Visualization Example

```python
# Upload heat_output.vtk to Colab first
!pip install matplotlib numpy

# Run visualization
!python visualize_heat_colab.py
```

## Performance Analysis

### Measuring Performance

All implementations include timing:
- Serial: Uses `clock()`
- Parallel: Uses `MPI_Wtime()`
- CUDA: Uses CUDA events

### Expected Metrics

Calculate:
- **Speedup** = T_serial / T_parallel
- **Efficiency** = Speedup / Number_of_processors
- **Scalability**: Test with 1, 2, 3 nodes

Example analysis:
```
Serial time: 45.2 seconds
Parallel (12 processes): 4.8 seconds
Speedup: 9.4x
Efficiency: 78.3%
```

## Troubleshooting

### Common Issues

**1. MPI processes don't converge:**
- Check ghost row exchange logic
- Verify boundary conditions are maintained
- Ensure all processes participate in MPI_Allreduce

**2. OpenMP performance degradation:**
- Check for race conditions
- Verify private/shared variable declarations
- Monitor thread affinity

**3. GPU out of memory:**
- Reduce grid size (NX, NY)
- Check data transfer patterns
- Verify memory is freed properly

**4. SLURM job fails:**
- Check module availability: `module avail`
- Verify resource requests match cluster limits
- Review error logs: `cat *.err`

## Assignment Deliverables

### Part 1 (60 points)
- [ ] `heat_parallel.c` with MPI + OpenMP
- [ ] `heat_job.slurm` script
- [ ] Report (2-3 pages):
  - Parallelization explanation
  - Challenges and solutions
  - Performance analysis

### Part 2 (40 points)
- [ ] `heat_gpu_openacc.c` or `heat_gpu_cuda.cu`
- [ ] Updated SLURM script (if applicable)
- [ ] Report (2-3 pages):
  - GPU implementation details
  - Challenges and solutions
  - Performance comparison

### Bonus (20 points)
- [ ] VTK output implementation
- [ ] Visualization scripts
- [ ] Generated images/screenshots
- [ ] Report section on visualization

## Build Automation

A Makefile is provided for convenience:

```bash
make all          # Build all versions
make serial       # Build serial only
make parallel     # Build MPI+OpenMP version
make gpu-cuda     # Build CUDA version
make clean        # Remove executables
```

## Useful Commands

### Check cluster status:
```bash
sinfo                    # Node availability
squeue                   # Job queue
scancel <job_id>         # Cancel job
sacct                    # Account information
```

### Performance profiling:
```bash
# CPU profiling
mpirun -np 4 perf stat ./heat_parallel

# GPU profiling
nvprof ./heat_gpu_cuda
```

## References

- [MPI Documentation](https://www.open-mpi.org/doc/)
- [OpenMP Documentation](https://www.openmp.org/specifications/)
- [CUDA Programming Guide](https://docs.nvidia.com/cuda/)
- [OpenACC Best Practices](https://www.openacc.org/resources)
- [VTK User Guide](https://vtk.org/documentation/)
- [SLURM Documentation](https://slurm.schedmd.com/documentation.html)

## Contact

For questions about the assignment, contact your instructor or TA.

## License

This code is provided for educational purposes as part of the HPC course assignment.
