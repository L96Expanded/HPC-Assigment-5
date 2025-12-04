# Windows PowerShell Build Script
# For building HPC Assignment on Windows (requires Microsoft MPI and Visual Studio or MinGW)

Write-Host "HPC Assignment Build Script for Windows" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for WSL availability first
$wslAvailable = Get-Command wsl -ErrorAction SilentlyContinue
if ($wslAvailable) {
    Write-Host "WSL detected! Recommended approach." -ForegroundColor Green
    Write-Host "To compile using WSL (Linux environment):" -ForegroundColor Yellow
    Write-Host "  wsl bash -c 'cd `"`$(wslpath -a `"$(Get-Location)`")`" && make all'" -ForegroundColor White
    Write-Host ""
    $useWSL = Read-Host "Use WSL to compile? (Y/N)"
    if ($useWSL -eq 'Y' -or $useWSL -eq 'y') {
        $currentPath = Get-Location
        wsl bash -c "cd `"`$(wslpath -a '$currentPath')`" && make all"
        exit
    }
}

Write-Host "Checking for compilation tools..." -ForegroundColor Yellow
Write-Host ""

# Check for gcc (MinGW)
$gccAvailable = Get-Command gcc -ErrorAction SilentlyContinue
if (-not $gccAvailable) {
    Write-Host "ERROR: gcc not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Options to compile on Windows:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Use WSL (Windows Subsystem for Linux) - RECOMMENDED" -ForegroundColor Green
    Write-Host "   - Install: wsl --install" -ForegroundColor White
    Write-Host "   - Then run: wsl" -ForegroundColor White
    Write-Host "   - Inside WSL: sudo apt install build-essential openmpi-bin libopenmpi-dev" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Install MinGW-w64" -ForegroundColor Green
    Write-Host "   - Download from: https://www.mingw-w64.org/" -ForegroundColor White
    Write-Host "   - Add to PATH: C:\mingw64\bin" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Install Microsoft MPI + Visual Studio" -ForegroundColor Green
    Write-Host "   - Download MS-MPI: https://docs.microsoft.com/en-us/message-passing-interface/microsoft-mpi" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Upload and compile directly on the cluster" -ForegroundColor Green
    Write-Host "   - scp *.c *.slurm username@hpcie.labs.faculty.ie.edu:~/assignment/" -ForegroundColor White
    Write-Host "   - ssh username@hpcie.labs.faculty.ie.edu" -ForegroundColor White
    Write-Host "   - bash compile.sh" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✓ gcc found" -ForegroundColor Green

# Check for mpicc
$mpiccAvailable = Get-Command mpicc -ErrorAction SilentlyContinue
if (-not $mpiccAvailable) {
    Write-Host "⚠ mpicc not found - will only compile serial version" -ForegroundColor Yellow
} else {
    Write-Host "✓ mpicc found" -ForegroundColor Green
}

# Check for nvcc
$nvccAvailable = Get-Command nvcc -ErrorAction SilentlyContinue
if (-not $nvccAvailable) {
    Write-Host "⚠ nvcc not found - GPU versions will be skipped" -ForegroundColor Yellow
} else {
    Write-Host "✓ nvcc found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Compiling..." -ForegroundColor Cyan
Write-Host ""

# Compile serial version
Write-Host "Building serial version..." -ForegroundColor Yellow
gcc -O3 -Wall -o heat_serial.exe heat_serial.c -lm
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ heat_serial.exe compiled successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to compile serial version" -ForegroundColor Red
}

# Compile VTK version
Write-Host "Building VTK output version..." -ForegroundColor Yellow
gcc -O3 -Wall -o heat_with_vtk.exe heat_with_vtk.c -lm
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ heat_with_vtk.exe compiled successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to compile VTK version" -ForegroundColor Red
}

# Compile parallel version if mpicc available
if ($mpiccAvailable) {
    Write-Host "Building parallel version (MPI + OpenMP)..." -ForegroundColor Yellow
    mpicc -fopenmp -O3 -o heat_parallel.exe heat_parallel.c -lm
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ heat_parallel.exe compiled successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to compile parallel version" -ForegroundColor Red
    }
}

# Compile CUDA version if nvcc available
if ($nvccAvailable) {
    Write-Host "Building CUDA version..." -ForegroundColor Yellow
    nvcc -O3 -o heat_gpu_cuda.exe heat_gpu_cuda.cu -lm
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ heat_gpu_cuda.exe compiled successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to compile CUDA version" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Build complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To run locally:" -ForegroundColor Yellow
Write-Host "  .\heat_serial.exe" -ForegroundColor White
Write-Host "  .\heat_with_vtk.exe" -ForegroundColor White
if ($mpiccAvailable) {
    Write-Host "  mpiexec -n 4 .\heat_parallel.exe" -ForegroundColor White
}
Write-Host ""
Write-Host "NOTE: For the actual assignment, compile and run on the cluster:" -ForegroundColor Cyan
Write-Host "  ssh username@hpcie.labs.faculty.ie.edu" -ForegroundColor White
Write-Host "  bash compile.sh" -ForegroundColor White
Write-Host "  sbatch heat_job.slurm" -ForegroundColor White
