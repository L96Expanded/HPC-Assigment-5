# Makefile for 2D Heat Equation Solver
# HPC Assignment Module 5

# Compilers
CC = gcc
MPICC = mpicc
NVCC = nvcc

# Compiler flags
CFLAGS = -O3 -Wall
OMPFLAGS = -fopenmp
MPIFLAGS = -fopenmp
CUDAFLAGS = -O3
ACCFLAGS = -fopenacc

# Libraries
LIBS = -lm

# Targets
TARGETS = heat_serial heat_parallel heat_with_vtk

# GPU targets (optional, may not compile without proper setup)
GPU_TARGETS = heat_gpu_cuda

# Default target
all: $(TARGETS)

# Serial version
heat_serial: heat_serial.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)
	@echo "Built serial version: $@"

# Parallel version (MPI + OpenMP)
heat_parallel: heat_parallel.c
	$(MPICC) $(MPIFLAGS) -o $@ $< $(LIBS)
	@echo "Built parallel version: $@"

# Serial version with VTK output
heat_with_vtk: heat_with_vtk.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)
	@echo "Built VTK version: $@"

# OpenACC GPU version (requires PGI/NVIDIA compiler)
heat_gpu_openacc: heat_gpu_openacc.c
	$(MPICC) $(OMPFLAGS) $(ACCFLAGS) -o $@ $< $(LIBS)
	@echo "Built OpenACC GPU version: $@"

# CUDA GPU version
heat_gpu_cuda: heat_gpu_cuda.cu
	$(NVCC) $(CUDAFLAGS) -o $@ $< $(LIBS)
	@echo "Built CUDA GPU version: $@"

# Build GPU versions if available
gpu: heat_gpu_cuda
	@echo "GPU versions built"

# Clean compiled files
clean:
	rm -f $(TARGETS) $(GPU_TARGETS) heat_gpu_openacc
	rm -f *.o *.out *.err
	rm -f heat_output.vtk
	rm -f *.png
	@echo "Cleaned all build artifacts"

# Run serial version
run-serial: heat_serial
	./heat_serial

# Run parallel version (example: 4 processes, 2 threads each)
run-parallel: heat_parallel
	export OMP_NUM_THREADS=2 && mpirun -np 4 ./heat_parallel

# Generate VTK output
run-vtk: heat_with_vtk
	./heat_with_vtk
	@echo "VTK output generated: heat_output.vtk"

# Test all CPU versions
test: heat_serial heat_parallel
	@echo "Testing serial version..."
	./heat_serial
	@echo ""
	@echo "Testing parallel version (2 processes, 2 threads)..."
	export OMP_NUM_THREADS=2 && mpirun -np 2 ./heat_parallel

# Help target
help:
	@echo "Available targets:"
	@echo "  all            - Build all CPU versions (default)"
	@echo "  serial         - Build serial version only"
	@echo "  parallel       - Build MPI+OpenMP version only"
	@echo "  gpu            - Build GPU versions (CUDA)"
	@echo "  clean          - Remove all compiled files"
	@echo "  run-serial     - Build and run serial version"
	@echo "  run-parallel   - Build and run parallel version"
	@echo "  run-vtk        - Build and generate VTK output"
	@echo "  test           - Build and test CPU versions"
	@echo "  help           - Show this help message"

.PHONY: all gpu clean run-serial run-parallel run-vtk test help
