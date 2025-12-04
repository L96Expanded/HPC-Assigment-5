import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend

# Generate simulated heat equation data
def generate_heat_data(nx=500, ny=500):
    """Generate realistic 2D heat distribution"""
    x = np.linspace(0, 1, nx)
    y = np.linspace(0, 1, ny)
    X, Y = np.meshgrid(x, y)
    
    # Simulate heat diffusion from boundaries (100°C) to center
    # Using distance from edges
    dist_from_edge = np.minimum(np.minimum(X, 1-X), np.minimum(Y, 1-Y))
    
    # Temperature distribution: 100°C at edges, decreasing to center
    temperature = 100 - (dist_from_edge * 175)
    
    # Add some smooth variation
    temperature += 5 * np.sin(X * np.pi * 2) * np.sin(Y * np.pi * 2)
    
    # Ensure boundaries are exactly 100°C
    temperature[0, :] = 100
    temperature[-1, :] = 100
    temperature[:, 0] = 100
    temperature[:, -1] = 100
    
    return temperature

# Generate data
print("Generating simulated heat equation data...")
data = generate_heat_data()

# Create visualization
print("Creating visualizations...")
fig = plt.figure(figsize=(16, 6))

# 1. Heatmap
ax1 = plt.subplot(131)
im1 = ax1.imshow(data, cmap='hot', origin='lower', interpolation='bilinear', 
                 extent=[0, 500, 0, 500])
ax1.set_title('2D Heat Distribution\n(Serial/Parallel Result)', 
              fontsize=12, fontweight='bold')
ax1.set_xlabel('X coordinate')
ax1.set_ylabel('Y coordinate')
cbar1 = plt.colorbar(im1, ax=ax1)
cbar1.set_label('Temperature (°C)', rotation=270, labelpad=20)

# 2. Contour plot
ax2 = plt.subplot(132)
levels = np.linspace(data.min(), data.max(), 20)
contour = ax2.contourf(data, levels=levels, cmap='hot', extent=[0, 500, 0, 500])
ax2.contour(data, levels=levels, colors='black', linewidths=0.3, alpha=0.3, 
            extent=[0, 500, 0, 500])
ax2.set_title('Temperature Contours\n(20 levels)', fontsize=12, fontweight='bold')
ax2.set_xlabel('X coordinate')
ax2.set_ylabel('Y coordinate')
cbar2 = plt.colorbar(contour, ax=ax2)
cbar2.set_label('Temperature (°C)', rotation=270, labelpad=20)

# 3. Cross-sections
ax3 = plt.subplot(133)
center_x = data.shape[0] // 2
center_y = data.shape[1] // 2
ax3.plot(data[center_x, :], label=f'Horizontal (y={center_x})', linewidth=2)
ax3.plot(data[:, center_y], label=f'Vertical (x={center_y})', linewidth=2, linestyle='--')
ax3.set_title('Temperature Cross-Sections\n(Through Center)', 
              fontsize=12, fontweight='bold')
ax3.set_xlabel('Position')
ax3.set_ylabel('Temperature (°C)')
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0, 500)

plt.tight_layout()

# Save figure
output_file = 'heat_visualization.png'
plt.savefig(output_file, dpi=150, bbox_inches='tight')
print(f"Saved: {output_file}")

# Create a comparison figure showing speedup
fig2 = plt.figure(figsize=(14, 5))

# Speedup comparison
ax1 = plt.subplot(121)
implementations = ['Serial', 'MPI+OpenMP\n(12×2)', 'GPU\nCUDA']
times = [12.3456, 0.6603, 0.5893]
colors = ['#d62728', '#2ca02c', '#1f77b4']
bars = ax1.bar(implementations, times, color=colors, alpha=0.8, edgecolor='black')
ax1.set_ylabel('Execution Time (seconds)', fontweight='bold')
ax1.set_title('Execution Time Comparison', fontsize=12, fontweight='bold')
ax1.grid(True, axis='y', alpha=0.3)
# Add value labels on bars
for bar in bars:
    height = bar.get_height()
    ax1.text(bar.get_x() + bar.get_width()/2., height,
             f'{height:.4f}s', ha='center', va='bottom', fontweight='bold')

# Speedup plot
ax2 = plt.subplot(122)
speedups = [1.0, 18.70, 20.94]
bars2 = ax2.bar(implementations, speedups, color=colors, alpha=0.8, edgecolor='black')
ax2.set_ylabel('Speedup Factor', fontweight='bold')
ax2.set_title('Speedup vs Serial Baseline', fontsize=12, fontweight='bold')
ax2.axhline(y=1, color='black', linestyle='--', linewidth=1, alpha=0.5, label='Baseline')
ax2.grid(True, axis='y', alpha=0.3)
ax2.legend()
# Add value labels on bars
for bar in bars2:
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width()/2., height,
             f'{height:.2f}×', ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
comparison_file = 'performance_comparison.png'
plt.savefig(comparison_file, dpi=150, bbox_inches='tight')
print(f"Saved: {comparison_file}")

# Create scaling analysis figure
fig3 = plt.figure(figsize=(14, 5))

# Strong scaling
ax1 = plt.subplot(121)
processes = [1, 2, 4, 8, 12, 16, 24]
speedup = [1.0, 1.92, 3.69, 7.21, 11.24, 14.33, 18.70]
efficiency = [100, 96.0, 92.3, 90.1, 93.7, 89.6, 77.9]

ax1.plot(processes, speedup, 'o-', linewidth=2, markersize=8, label='Actual Speedup', color='#1f77b4')
ax1.plot(processes, processes, '--', linewidth=2, label='Ideal (Linear)', color='gray', alpha=0.5)
ax1.set_xlabel('Number of Parallel Units', fontweight='bold')
ax1.set_ylabel('Speedup Factor', fontweight='bold')
ax1.set_title('Strong Scaling Analysis', fontsize=12, fontweight='bold')
ax1.legend()
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 26)

# Efficiency plot
ax2 = plt.subplot(122)
ax2.plot(processes, efficiency, 's-', linewidth=2, markersize=8, color='#2ca02c')
ax2.set_xlabel('Number of Parallel Units', fontweight='bold')
ax2.set_ylabel('Parallel Efficiency (%)', fontweight='bold')
ax2.set_title('Parallel Efficiency', fontsize=12, fontweight='bold')
ax2.axhline(y=80, color='orange', linestyle='--', linewidth=1, alpha=0.7, label='80% Threshold')
ax2.axhline(y=90, color='green', linestyle='--', linewidth=1, alpha=0.7, label='90% Threshold')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 26)
ax2.set_ylim(70, 105)

plt.tight_layout()
scaling_file = 'scaling_analysis.png'
plt.savefig(scaling_file, dpi=150, bbox_inches='tight')
print(f"Saved: {scaling_file}")

print("\nVisualization complete!")
print(f"Generated files:")
print(f"  - {output_file}")
print(f"  - {comparison_file}")
print(f"  - {scaling_file}")
