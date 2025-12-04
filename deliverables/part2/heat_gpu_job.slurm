#!/bin/bash
#SBATCH --job-name=heat_gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=heat_gpu.out
#SBATCH --error=heat_gpu.err
#SBATCH --partition=gpu
#SBATCH --account=user51

# Cluster credentials embedded for reference
# Username: user51@login1.hpcie.labs.faculty.ie.edu
# Connection: ssh user51@login1.hpcie.labs.faculty.ie.edu

# Load required modules
module load cuda/11.0
module load gcc/9.3.0
module load openmpi/4.0.3

# Print job information
echo "========================================"
echo "HPC Assignment - Part 2: GPU Acceleration"
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
echo "  GPU count: 1"
echo "  GPU devices: $CUDA_VISIBLE_DEVICES"
echo ""
echo "GPU Information:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
echo ""
echo "========================================"
echo ""

# Run the GPU application (CUDA version)
echo "Starting heat_gpu_cuda execution..."
echo ""
./heat_gpu_cuda

echo ""
echo "========================================"
echo "Job finished at: $(date)"
echo "========================================"
