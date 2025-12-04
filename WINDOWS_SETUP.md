# Quick Setup Guide for Windows Users

## The Issue

The code is designed to run on a Linux HPC cluster, but you're on Windows. The Makefile uses Linux tools (gcc, mpicc) that aren't available by default on Windows.

## Solutions (Choose One)

### Option 1: Use WSL (RECOMMENDED) ⭐

Windows Subsystem for Linux lets you run Linux tools natively on Windows.

**⚠️ IMPORTANT: You have Docker Desktop's WSL, not a full Linux distribution.**

Docker's WSL doesn't have package managers or development tools. You need a proper Linux distribution.

**Install a proper WSL distribution:**
```powershell
# List available distributions
wsl --list --online

# Install Ubuntu (recommended)
wsl --install -d Ubuntu

# After installation, launch Ubuntu
wsl -d Ubuntu

# Inside Ubuntu, install required tools
sudo apt update
sudo apt install build-essential openmpi-bin libopenmpi-dev

# Navigate to your project (avoid OneDrive paths - see Option 3A below)
cd /mnt/c/Projects/HPC

# Now you can use the Makefile
make all
```

**Note about OneDrive:** WSL has trouble with OneDrive paths. See Option 3A below for the workaround.

### Option 2: Use the Build Script

Run the PowerShell build script I've created:

```powershell
.\build.ps1
```

This will:
- Check for available compilers
- Compile what it can
- Give you helpful guidance

### Option 3: Upload to Cluster and Compile There ⭐⭐⭐

**This is what you'll do for the final submission anyway! RECOMMENDED FOR YOUR SITUATION.**

```powershell
# Copy files to cluster
scp *.c *.cu *.slurm compile.sh username@hpcie.labs.faculty.ie.edu:~/assignment/

# Connect to cluster
ssh username@hpcie.labs.faculty.ie.edu

# On the cluster, compile
cd ~/assignment
bash compile.sh

# Submit job
sbatch heat_job.slurm

# Check results
cat heat_parallel.out
```

### Option 3A: Copy Files Outside OneDrive (for WSL)

If you want to use WSL with a proper Ubuntu installation:

```powershell
# Create a non-OneDrive folder
mkdir C:\Projects\HPC
cd C:\Projects\HPC

# Copy all files
Copy-Item "C:\Users\david\OneDrive\Documents\School\HPC\Assignment HPC Module 5\*" -Destination . -Recurse

# Now WSL can access it (after installing Ubuntu WSL)
wsl -d Ubuntu
cd /mnt/c/Projects/HPC
make all
```

### Option 4: Install MinGW-w64

If you want native Windows compilation:

1. Download MinGW-w64: https://www.mingw-w64.org/downloads/
2. Install and add to PATH: `C:\mingw64\bin`
3. Restart PowerShell
4. Run: `.\build.ps1`

**Note:** MinGW won't have MPI, so you can only compile the serial version locally.

## What to Do Now

**For local testing (serial version only):**
```powershell
.\build.ps1
```

**For the actual assignment (recommended):**
Just work directly on the cluster - the code is designed for it!

```powershell
# Upload files
scp -r . username@hpcie.labs.faculty.ie.edu:~/assignment/

# Connect and compile
ssh username@hpcie.labs.faculty.ie.edu
cd ~/assignment
bash compile.sh
```

## Running the Code

**On Windows (if compiled with build.ps1):**
```powershell
.\heat_serial.exe
.\heat_with_vtk.exe
```

**On Cluster (for submission):**
```bash
sbatch heat_job.slurm
sbatch heat_gpu_job.slurm
```

## Bottom Line

💡 **The assignment is designed to run on the HPC cluster, not Windows.**

The easiest path:
1. Use WSL for local development/testing (optional)
2. Upload everything to the cluster for actual runs
3. Submit your jobs with SLURM

You don't need to compile on Windows at all - you can edit the code locally and compile/run on the cluster!
