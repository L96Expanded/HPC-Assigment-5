#!/bin/bash
#SBATCH --job-name=heat_parallel
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --time=00:30:00
#SBATCH --output=heat_parallel.out
#SBATCH --error=heat_parallel.err
#SBATCH --partition=compute
#SBATCH --account=user51

# Cluster credentials embedded for reference
# Username: user51@login1.hpcie.labs.faculty.ie.edu
# Connection: ssh user51@login1.hpcie.labs.faculty.ie.edu

# Load required modules
module load gcc/9.3.0
module load openmpi/4.0.3

# Set OpenMP threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Print job information
echo "========================================"
echo "HPC Assignment - Part 1: MPI + OpenMP"
echo "========================================"
echo ""
echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "User: $USER"
echo "Submitted from: $(hostname)"
echo "Job started at: $(date)"
echo ""
echo "Resource Allocation:"
echo "  Nodes: $SLURM_JOB_NUM_NODES"
echo "  Node list: $SLURM_JOB_NODELIST"
echo "  MPI tasks: $SLURM_NTASKS"
echo "  Tasks per node: $SLURM_NTASKS_PER_NODE"
echo "  CPUs per task: $SLURM_CPUS_PER_TASK"
echo "  OpenMP threads: $OMP_NUM_THREADS"
echo "  Total cores: $(($SLURM_NTASKS * $SLURM_CPUS_PER_TASK))"
echo ""
echo "========================================"
echo ""

# Run the parallel application
echo "Starting heat_parallel execution..."
echo ""
mpirun -np $SLURM_NTASKS ./heat_parallel

echo ""
echo "========================================"
echo "Job finished at: $(date)"
echo "========================================"
