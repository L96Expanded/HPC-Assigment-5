# HPC Assignment - Cluster Deployment Guide
## User: user51@login1.hpcie.labs.faculty.ie.edu

## Part 1: MPI + OpenMP Parallelization

### Step 1: Connect to Cluster
```bash
ssh user51@login1.hpcie.labs.faculty.ie.edu
# Password: passwd
```

### Step 2: Create Working Directory
```bash
mkdir -p ~/hpc_assignment/part1
cd ~/hpc_assignment/part1
```

### Step 3: Upload Files
From your local machine:
```powershell
# Upload Part 1 files
scp heat_serial.c user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part1/
scp heat_parallel.c user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part1/
scp heat_job.slurm user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part1/
```

### Step 4: Compile on Cluster
```bash
# Load modules
module load gcc/9.3.0
module load openmpi/4.0.3

# Compile serial version
gcc -O3 -o heat_serial heat_serial.c -lm

# Compile parallel version
mpicc -fopenmp -O3 -o heat_parallel heat_parallel.c -lm
```

### Step 5: Run Serial Version (for baseline)
```bash
./heat_serial
```

### Step 6: Submit Parallel Job
```bash
sbatch heat_job.slurm
```

### Step 7: Monitor Job
```bash
# Check job status
squeue -u user51

# View output (after job completes)
cat heat_parallel.out
```

## Part 2: GPU Acceleration

### Step 1: Setup Part 2 Directory
```bash
mkdir -p ~/hpc_assignment/part2
cd ~/hpc_assignment/part2
```

### Step 2: Upload Files
From your local machine:
```powershell
# Upload Part 2 files
scp heat_gpu_cuda.cu user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part2/
scp heat_gpu_job.slurm user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part2/
```

### Step 3: Compile GPU Version
```bash
# Load modules
module load cuda/11.0
module load gcc/9.3.0

# Compile CUDA version
nvcc -O3 -o heat_gpu_cuda heat_gpu_cuda.cu -lm
```

### Step 4: Submit GPU Job
```bash
sbatch heat_gpu_job.slurm
```

### Step 5: Check Results
```bash
# Monitor job
squeue -u user51

# View output
cat heat_gpu.out
```

## Part 3 (Bonus): Visualization

### Step 1: Setup Part 3 Directory
```bash
mkdir -p ~/hpc_assignment/part3
cd ~/hpc_assignment/part3
```

### Step 2: Upload Files
```powershell
# Upload Part 3 files
scp heat_with_vtk.c user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part3/
scp visualize_heat_colab.py user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part3/
```

### Step 3: Generate VTK Data
```bash
# Compile
gcc -O3 -o heat_with_vtk heat_with_vtk.c -lm

# Run
./heat_with_vtk

# This creates heat_output.vtk
```

### Step 4: Download VTK File for Local Visualization
```powershell
# From local machine
scp user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/part3/heat_output.vtk .
```

### Step 5: Visualize Locally
```powershell
# Install dependencies
pip install matplotlib numpy

# Run visualization
python visualize_heat_colab.py
```

## Useful Cluster Commands

### Check Job Status
```bash
squeue -u user51                    # Your jobs
squeue                               # All jobs
scancel <job_id>                    # Cancel a job
sacct -u user51                     # Job history
```

### Check Cluster Resources
```bash
sinfo                                # Node availability
sinfo -p compute                    # Compute partition
sinfo -p gpu                        # GPU partition
```

### Module Management
```bash
module avail                         # Available modules
module list                          # Loaded modules
module load <module>                # Load a module
module unload <module>              # Unload a module
```

### File Management
```bash
# Check disk usage
du -sh ~/hpc_assignment

# Archive results
tar -czf results.tar.gz ~/hpc_assignment

# Download results
# From local machine:
# scp user51@login1.hpcie.labs.faculty.ie.edu:~/hpc_assignment/results.tar.gz .
```

## Troubleshooting

### Job Not Starting
```bash
# Check job details
scontrol show job <job_id>

# Check node availability
sinfo -N -l
```

### Compilation Errors
```bash
# Verify modules loaded
module list

# Check compiler versions
gcc --version
mpicc --version
nvcc --version
```

### Performance Issues
```bash
# View detailed timing in output files
cat heat_parallel.out
cat heat_gpu.out
```

## Quick Reference

**Login:** `ssh user51@login1.hpcie.labs.faculty.ie.edu`  
**Password:** `passwd`  
**Workflow:** Upload → Compile → Submit → Monitor → Download Results  
**Support:** Contact instructor or check cluster documentation
