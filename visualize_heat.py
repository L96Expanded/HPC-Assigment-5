"""
VTK Visualization Script for 2D Heat Equation
This script reads the VTK output file and creates visualizations
"""

import vtk
import sys

def visualize_heat_distribution(filename='heat_output.vtk'):
    """
    Visualize the heat distribution from a VTK file
    
    Args:
        filename: Path to the VTK file
    """
    # Read data from file
    reader = vtk.vtkStructuredPointsReader()
    reader.SetFileName(filename)
    reader.Update()
    
    # Create a lookup table for temperature colors (blue to red)
    lut = vtk.vtkLookupTable()
    lut.SetNumberOfColors(256)
    lut.SetHueRange(0.667, 0.0)  # Blue to red
    lut.Build()
    
    # Create a mapper
    mapper = vtk.vtkDataSetMapper()
    mapper.SetInputConnection(reader.GetOutputPort())
    mapper.SetLookupTable(lut)
    mapper.SetScalarRange(0, 100)  # Temperature range
    
    # Create an actor
    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    
    # Create a scalar bar (color legend)
    scalar_bar = vtk.vtkScalarBarActor()
    scalar_bar.SetLookupTable(lut)
    scalar_bar.SetTitle("Temperature")
    scalar_bar.SetNumberOfLabels(5)
    
    # Create a renderer
    renderer = vtk.vtkRenderer()
    renderer.AddActor(actor)
    renderer.AddActor2D(scalar_bar)
    renderer.SetBackground(1, 1, 1)  # White background
    
    # Create a render window
    render_window = vtk.vtkRenderWindow()
    render_window.AddRenderer(renderer)
    render_window.SetSize(800, 600)
    render_window.SetWindowName("2D Heat Distribution")
    
    # Create an interactor
    interactor = vtk.vtkRenderWindowInteractor()
    interactor.SetRenderWindow(render_window)
    
    # Set up camera for 2D view
    camera = renderer.GetActiveCamera()
    camera.ParallelProjectionOn()
    renderer.ResetCamera()
    
    # Start the visualization
    render_window.Render()
    interactor.Start()

def save_visualization_image(filename='heat_output.vtk', output_image='heat_visualization.png'):
    """
    Save the visualization as an image file
    
    Args:
        filename: Path to the VTK file
        output_image: Path to save the output image
    """
    # Read data from file
    reader = vtk.vtkStructuredPointsReader()
    reader.SetFileName(filename)
    reader.Update()
    
    # Create a lookup table
    lut = vtk.vtkLookupTable()
    lut.SetNumberOfColors(256)
    lut.SetHueRange(0.667, 0.0)  # Blue to red
    lut.Build()
    
    # Create a mapper
    mapper = vtk.vtkDataSetMapper()
    mapper.SetInputConnection(reader.GetOutputPort())
    mapper.SetLookupTable(lut)
    mapper.SetScalarRange(0, 100)
    
    # Create an actor
    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    
    # Create a scalar bar
    scalar_bar = vtk.vtkScalarBarActor()
    scalar_bar.SetLookupTable(lut)
    scalar_bar.SetTitle("Temperature")
    scalar_bar.SetNumberOfLabels(5)
    
    # Create a renderer
    renderer = vtk.vtkRenderer()
    renderer.AddActor(actor)
    renderer.AddActor2D(scalar_bar)
    renderer.SetBackground(1, 1, 1)
    
    # Create a render window
    render_window = vtk.vtkRenderWindow()
    render_window.AddRenderer(renderer)
    render_window.SetSize(800, 600)
    render_window.SetOffScreenRendering(1)
    
    # Set up camera
    camera = renderer.GetActiveCamera()
    camera.ParallelProjectionOn()
    renderer.ResetCamera()
    
    # Render and save
    render_window.Render()
    
    # Create window to image filter
    w2i = vtk.vtkWindowToImageFilter()
    w2i.SetInput(render_window)
    w2i.Update()
    
    # Write PNG file
    writer = vtk.vtkPNGWriter()
    writer.SetFileName(output_image)
    writer.SetInputConnection(w2i.GetOutputPort())
    writer.Write()
    
    print(f"Visualization saved to: {output_image}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        vtk_file = sys.argv[1]
    else:
        vtk_file = 'heat_output.vtk'
    
    print(f"Reading VTK file: {vtk_file}")
    
    # Save image first
    save_visualization_image(vtk_file, 'heat_visualization.png')
    
    # Then display interactive window
    print("Launching interactive visualization...")
    print("Press 'q' to quit the visualization window")
    visualize_heat_distribution(vtk_file)
