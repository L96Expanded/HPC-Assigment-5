#!/bin/bash
#SBATCH --job-name=heat_gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=heat_gpu.out
#SBATCH --error=heat_gpu.err

# Load required modules
module load cuda/11.0
module load gcc/9.3.0

# Print job information
echo "Job started at: $(date)"
echo "Running on node: $HOSTNAME"
echo "GPU devices: $CUDA_VISIBLE_DEVICES"

# Run the GPU application (CUDA version)
./heat_gpu_cuda

echo "Job finished at: $(date)"
