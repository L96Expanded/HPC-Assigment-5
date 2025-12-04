# Simple Windows Compilation Guide

## The Problem

Your files are in OneDrive, which WSL can't access easily. Also, you need Linux tools (gcc, mpicc) to compile.

## Easiest Solution: Just Test the Serial Version Locally

Since the actual assignment MUST run on the cluster anyway, you only need to verify the code compiles:

### Step 1: Install MinGW (if not installed)

Download and install: https://winlibs.com/ or https://www.msys2.org/

### Step 2: Compile Serial Version

```powershell
# Simple test compile (if you have gcc)
gcc -O3 -o heat_serial.exe heat_serial.c -lm

# Run it
.\heat_serial.exe
```

### Step 3: Compile VTK Version

```powershell
gcc -O3 -o heat_with_vtk.exe heat_with_vtk.c -lm
.\heat_with_vtk.exe
```

## Better Solution: Work Directly on the Cluster

Since you need the cluster for the actual assignment, why not just develop there?

### Option A: Edit locally, compile remotely

```powershell
# Upload your files (replace 'username' with your actual username)
scp heat_serial.c heat_parallel.c heat_gpu_cuda.cu heat_*.slurm compile.sh username@hpcie.labs.faculty.ie.edu:~/assignment/

# Connect to cluster
ssh username@hpcie.labs.faculty.ie.edu

# On the cluster:
cd ~/assignment
bash compile.sh
sbatch heat_job.slurm
```

### Option B: Use VS Code Remote SSH

Much better developer experience:

1. Install "Remote - SSH" extension in VS Code
2. Connect to `hpcie.labs.faculty.ie.edu`
3. Open the folder
4. Edit and compile directly on the cluster

## If You Really Want WSL

The issue is OneDrive. Copy files to a regular Windows folder:

```powershell
# Create a folder outside OneDrive
mkdir C:\Projects\HPC
cd C:\Projects\HPC

# Copy files
Copy-Item "C:\Users\david\OneDrive\Documents\School\HPC\Assignment HPC Module 5\*" -Destination . -Recurse

# Now WSL can access it
wsl sh -c "cd /mnt/c/Projects/HPC && make all"
```

## Recommended Workflow

**For this assignment, I recommend:**

1. ✅ Edit code in VS Code on Windows (where you are now)
2. ✅ Upload to cluster: `scp -r . username@hpcie.labs.faculty.ie.edu:~/assignment/`
3. ✅ Compile on cluster: `ssh username@hpcie.labs.faculty.ie.edu "cd assignment && bash compile.sh"`
4. ✅ Run on cluster: `ssh username@hpcie.labs.faculty.ie.edu "cd assignment && sbatch heat_job.slurm"`
5. ✅ Download results: `scp username@hpcie.labs.faculty.ie.edu:~/assignment/*.out .`

**You don't need to compile locally at all!** The assignment requires cluster execution anyway.

## Quick Test Without Compiling

If you just want to verify the code syntax:

```powershell
# Check for syntax errors (requires gcc)
gcc -fsyntax-only heat_serial.c
gcc -fsyntax-only heat_parallel.c
```

## What's Next?

Choose one:
- [ ] Install MinGW and compile serial version only (for testing)
- [ ] Copy files outside OneDrive and use WSL
- [ ] Skip local compilation and go straight to cluster (RECOMMENDED)
