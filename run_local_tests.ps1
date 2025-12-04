# Build and Run All Local Test Versions
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "HPC Assignment - Local Testing" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$hasGCC = Get-Command gcc -ErrorAction SilentlyContinue

if (-not $hasGCC) {
    Write-Host "ERROR: gcc not found!" -ForegroundColor Red
    Write-Host "Please install MinGW or use WSL" -ForegroundColor Yellow
    exit 1
}

Write-Host "GCC compiler found" -ForegroundColor Green
Write-Host ""

# Change to local_test directory
Set-Location local_test

# Compile all versions
Write-Host "Compiling programs..." -ForegroundColor Yellow
Write-Host "--------------------" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Compiling serial version..." -ForegroundColor Cyan
gcc -O3 -o heat_serial_local.exe heat_serial_local.c -lm
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "   Success" -ForegroundColor Green

Write-Host "2. Compiling parallel (simulated) version..." -ForegroundColor Cyan
gcc -O3 -o heat_parallel_simulated.exe heat_parallel_simulated.c -lm
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "   Success" -ForegroundColor Green

Write-Host "3. Compiling GPU (simulated) version..." -ForegroundColor Cyan
gcc -O3 -o heat_gpu_simulated.exe heat_gpu_simulated.c -lm
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "   Success" -ForegroundColor Green

Write-Host "4. Compiling VTK output version..." -ForegroundColor Cyan
gcc -O3 -o heat_vtk_local.exe heat_vtk_local.c -lm
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "   Success" -ForegroundColor Green

# Run all versions
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Running Programs" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] Running SERIAL version..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
.\heat_serial_local.exe | Tee-Object -FilePath "serial_output.txt"

Write-Host ""
Write-Host "[2/4] Running PARALLEL (simulated) version..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
.\heat_parallel_simulated.exe | Tee-Object -FilePath "parallel_output.txt"

Write-Host ""
Write-Host "[3/4] Running GPU (simulated) version..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
.\heat_gpu_simulated.exe | Tee-Object -FilePath "gpu_output.txt"

Write-Host ""
Write-Host "[4/4] Running VTK OUTPUT version..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
.\heat_vtk_local.exe | Tee-Object -FilePath "vtk_output.txt"

# Summary
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Execution Complete!" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Output files created:" -ForegroundColor Green
Write-Host "  - serial_output.txt"
Write-Host "  - parallel_output.txt"
Write-Host "  - gpu_output.txt"
Write-Host "  - vtk_output.txt"
if (Test-Path "heat_output.vtk") {
    Write-Host "  - heat_output.vtk (visualization data)"
}
Write-Host ""

Write-Host "All tests completed successfully!" -ForegroundColor Green

Set-Location ..
