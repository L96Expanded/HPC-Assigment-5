#!/bin/bash
#SBATCH --job-name=heat_parallel
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --time=00:30:00
#SBATCH --output=heat_parallel.out
#SBATCH --error=heat_parallel.err

# Load required modules
module load gcc/9.3.0
module load openmpi/4.0.3

# Set OpenMP threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Print job information
echo "Job started at: $(date)"
echo "Running on nodes: $SLURM_JOB_NODELIST"
echo "Number of MPI tasks: $SLURM_NTASKS"
echo "OpenMP threads per task: $OMP_NUM_THREADS"

# Run the parallel application
mpirun -np $SLURM_NTASKS ./heat_parallel

echo "Job finished at: $(date)"
