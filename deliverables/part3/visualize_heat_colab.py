"""
Simplified VTK Visualization for Google Colab
This version uses matplotlib for inline visualization in Colab
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

def read_vtk_file(filename='heat_output.vtk'):
    """
    Read temperature data from VTK file
    
    Args:
        filename: Path to the VTK file
        
    Returns:
        nx, ny: Grid dimensions
        data: 2D numpy array of temperature values
    """
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    # Parse header to get dimensions
    for i, line in enumerate(lines):
        if 'DIMENSIONS' in line:
            parts = line.split()
            nx, ny = int(parts[1]), int(parts[2])
            break
    
    # Find where data starts
    data_start = 0
    for i, line in enumerate(lines):
        if 'LOOKUP_TABLE' in line:
            data_start = i + 1
            break
    
    # Read temperature data
    temps = []
    for i in range(data_start, len(lines)):
        if lines[i].strip():
            temps.append(float(lines[i].strip()))
    
    # Reshape to 2D array
    data = np.array(temps).reshape(ny, nx)
    
    return nx, ny, data

def visualize_heat_colab(filename='heat_output.vtk'):
    """
    Create visualization suitable for Google Colab
    
    Args:
        filename: Path to the VTK file
    """
    # Read data
    nx, ny, data = read_vtk_file(filename)
    
    # Create figure
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
    
    # Plot 1: Heatmap with colorbar
    im1 = ax1.imshow(data, cmap='hot', origin='lower', interpolation='bilinear')
    ax1.set_title('2D Heat Distribution', fontsize=14, fontweight='bold')
    ax1.set_xlabel('X coordinate')
    ax1.set_ylabel('Y coordinate')
    cbar1 = plt.colorbar(im1, ax=ax1)
    cbar1.set_label('Temperature', rotation=270, labelpad=20)
    
    # Plot 2: Contour plot
    x = np.arange(nx)
    y = np.arange(ny)
    X, Y = np.meshgrid(x, y)
    
    levels = np.linspace(data.min(), data.max(), 20)
    contour = ax2.contourf(X, Y, data, levels=levels, cmap='hot')
    ax2.set_title('Temperature Contours', fontsize=14, fontweight='bold')
    ax2.set_xlabel('X coordinate')
    ax2.set_ylabel('Y coordinate')
    cbar2 = plt.colorbar(contour, ax=ax2)
    cbar2.set_label('Temperature', rotation=270, labelpad=20)
    
    plt.tight_layout()
    plt.savefig('heat_visualization_colab.png', dpi=150, bbox_inches='tight')
    print("Visualization saved to: heat_visualization_colab.png")
    plt.show()
    
    # Print statistics
    print("\nTemperature Statistics:")
    print(f"  Minimum: {data.min():.2f}")
    print(f"  Maximum: {data.max():.2f}")
    print(f"  Mean: {data.mean():.2f}")
    print(f"  Std Dev: {data.std():.2f}")

def plot_cross_sections(filename='heat_output.vtk'):
    """
    Plot cross-sections of the temperature distribution
    
    Args:
        filename: Path to the VTK file
    """
    # Read data
    nx, ny, data = read_vtk_file(filename)
    
    # Create figure for cross-sections
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
    
    # Horizontal cross-section (middle row)
    mid_y = ny // 2
    ax1.plot(data[mid_y, :], linewidth=2)
    ax1.set_title(f'Horizontal Cross-Section (y = {mid_y})', fontsize=14, fontweight='bold')
    ax1.set_xlabel('X coordinate')
    ax1.set_ylabel('Temperature')
    ax1.grid(True, alpha=0.3)
    
    # Vertical cross-section (middle column)
    mid_x = nx // 2
    ax2.plot(data[:, mid_x], linewidth=2)
    ax2.set_title(f'Vertical Cross-Section (x = {mid_x})', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Y coordinate')
    ax2.set_ylabel('Temperature')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('heat_cross_sections.png', dpi=150, bbox_inches='tight')
    print("Cross-section plot saved to: heat_cross_sections.png")
    plt.show()

# Example usage in Colab
if __name__ == "__main__":
    # For use in Google Colab
    print("2D Heat Equation Visualization")
    print("=" * 50)
    
    vtk_file = 'heat_output.vtk'
    
    # Check if file exists
    import os
    if not os.path.exists(vtk_file):
        print(f"Error: File {vtk_file} not found!")
        print("Please ensure the VTK file is uploaded or generated first.")
    else:
        print(f"Reading data from: {vtk_file}\n")
        visualize_heat_colab(vtk_file)
        print("\n")
        plot_cross_sections(vtk_file)
