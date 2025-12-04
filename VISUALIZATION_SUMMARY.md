# Heat Simulation Visualization Summary

## Successfully Generated Files

### Executable
- **heat_vtk_small.exe** - Compiled heat simulation (200x200 grid)
  - Uses dynamic memory allocation to avoid stack overflow
  - Reduced grid size from 500x500 to 200x200 for faster computation
  - Generates VTK output file

### Data File
- **heat_output.vtk** (425 KB) - VTK format output containing temperature data
  - Grid: 200x200 points
  - Temperature range: 0 to 100
  - Boundary conditions: 100°C on all edges
  - Interior: Solved using iterative Jacobi method

### Visualization Images

1. **heat_visualization.png** (57 KB)
   - Generated using VTK library
   - Shows 2D heat distribution with color legend
   - Interactive visualization window available

2. **heat_visualization_colab.png** (116 KB)
   - Dual-plot visualization using matplotlib
   - Left: Heatmap with colorbar
   - Right: Contour plot showing temperature gradients

3. **heat_cross_sections.png** (77 KB)
   - Cross-sectional views through the middle of the domain
   - Left: Horizontal slice (constant Y)
   - Right: Vertical slice (constant X)

## Simulation Results

**Grid Configuration:**
- Size: 200 x 200 points
- Maximum iterations: 1000
- Convergence tolerance: 1e-6

**Temperature Statistics:**
- Minimum: 0.00°C (center of domain)
- Maximum: 100.00°C (boundaries)
- Mean: 33.33°C
- Standard Deviation: 32.71°C

**Convergence:**
- Reached maximum iterations (1000)
- Final max_diff: ~0.04
- Note: Did not fully converge to tolerance (would need more iterations)

## How to Run

### 1. Compile the simulation:
```powershell
gcc -O2 -o heat_vtk_small.exe heat_vtk_small.c -lm
```

### 2. Run the simulation:
```powershell
.\heat_vtk_small.exe
```

### 3. Visualize with VTK (interactive):
```powershell
python visualize_heat.py heat_output.vtk
```

### 4. Visualize with Matplotlib (static images):
```powershell
python visualize_heat_colab.py
```

## Installed Python Packages

```
vtk==9.5.2
numpy==2.3.5
matplotlib==3.10.7
```

## Key Modifications

### Modified from Original Code:
1. **Changed grid size** from 500x500 to 200x200
   - Reduces memory footprint
   - Faster computation time
   - Avoids stack overflow on Windows

2. **Dynamic memory allocation**
   - Used `malloc()` instead of static arrays
   - Prevents stack overflow with large grids
   - Properly freed memory after use

3. **Added progress output**
   - Prints every 100 iterations
   - Shows convergence progress
   - Helps debug long-running simulations

## Physical Interpretation

The simulation models **steady-state heat conduction** in a 2D square domain:

- **Boundaries**: Fixed at 100°C (Dirichlet boundary conditions)
- **Interior**: Starts at 0°C
- **Physics**: Heat diffuses from hot boundaries toward cold center
- **Method**: Iterative Jacobi solver (5-point stencil)

The result shows the expected pattern:
- Hot boundaries (red/yellow)
- Cooler center (blue/cyan)
- Smooth temperature gradient from edges to center
- Symmetrical distribution (as expected for square domain)

## Next Steps for Full Assignment

1. **For larger grids**: Use the original 500x500 or larger
2. **For parallel version**: Implement MPI domain decomposition
3. **For GPU version**: Port to CUDA or OpenACC
4. **Run on HPC cluster**: Use SLURM scripts provided
5. **Compare performance**: Serial vs Parallel vs GPU

## File Locations

All files are located in:
```
C:\Users\david\OneDrive\Documents\School\HPC\Assignment HPC Module 5\
```

## Viewing the Results

The PNG files can be opened with any image viewer or directly in VS Code.
The VTK file can be opened in ParaView for advanced 3D visualization options.
