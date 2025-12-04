#!/bin/bash
# Compile script for HPC cluster
# Run this after connecting to hpcie.labs.faculty.ie.edu

echo "Loading required modules..."
module load gcc/9.3.0
module load openmpi/4.0.3

echo ""
echo "Compiling serial version..."
gcc -O3 -o heat_serial heat_serial.c -lm
if [ $? -eq 0 ]; then
    echo "✓ Serial version compiled successfully"
else
    echo "✗ Failed to compile serial version"
    exit 1
fi

echo ""
echo "Compiling parallel version (MPI + OpenMP)..."
mpicc -fopenmp -O3 -o heat_parallel heat_parallel.c -lm
if [ $? -eq 0 ]; then
    echo "✓ Parallel version compiled successfully"
else
    echo "✗ Failed to compile parallel version"
    exit 1
fi

echo ""
echo "Compiling VTK output version..."
gcc -O3 -o heat_with_vtk heat_with_vtk.c -lm
if [ $? -eq 0 ]; then
    echo "✓ VTK version compiled successfully"
else
    echo "✗ Failed to compile VTK version"
    exit 1
fi

echo ""
echo "All CPU versions compiled successfully!"
echo ""
echo "To compile GPU versions, run:"
echo "  module load cuda/11.0"
echo "  nvcc -O3 -o heat_gpu_cuda heat_gpu_cuda.cu -lm"
echo ""
echo "To submit jobs, use:"
echo "  sbatch heat_job.slurm          # For CPU parallel"
echo "  sbatch heat_gpu_job.slurm      # For GPU"
