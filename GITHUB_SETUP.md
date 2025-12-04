# GitHub Repository Setup Guide

## Quick Setup (PowerShell)

### 1. Initialize Git Repository

```powershell
# Navigate to project directory
cd "C:\Users\david\OneDrive\Documents\School\HPC\Assignment HPC Module 5"

# Initialize git
git init

# Add all files
git add .

# Make initial commit
git commit -m "Initial commit: 2D Heat Equation Solver with MPI+OpenMP+CUDA"
```

### 2. Create GitHub Repository

Go to [GitHub](https://github.com/new) and create a new repository:

- **Repository name:** `heat-equation-hpc` (or your preferred name)
- **Description:** `High-Performance Computing implementation of 2D heat equation solver with MPI+OpenMP+CUDA`
- **Visibility:** Public (or Private if you prefer)
- **Do NOT initialize with README, .gitignore, or license** (we already have these)

### 3. Connect to GitHub

After creating the repository on GitHub, run:

```powershell
# Add remote repository (replace 'yourusername' with your GitHub username)
git remote add origin https://github.com/yourusername/heat-equation-hpc.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 4. Verify Upload

Visit your repository at: `https://github.com/yourusername/heat-equation-hpc`

---

## Alternative: Using GitHub Desktop

1. **Download GitHub Desktop:** https://desktop.github.com/
2. **Open GitHub Desktop**
3. **File → Add Local Repository**
4. Browse to: `C:\Users\david\OneDrive\Documents\School\HPC\Assignment HPC Module 5`
5. Click **"Add Repository"**
6. Click **"Publish Repository"** in the top toolbar
7. Fill in repository details and click **"Publish Repository"**

---

## What Gets Uploaded

Based on the `.gitignore` file, these files will be included:

✅ **Source Code:**
- heat_serial.c
- heat_parallel.c
- heat_gpu_cuda.cu
- heat_gpu_openacc.c
- heat_with_vtk.c
- visualize_heat_colab.py
- visualize_heat.py

✅ **Documentation:**
- README.md
- deliverables/README.md
- deliverables/CLUSTER_DEPLOYMENT_GUIDE.md
- deliverables/part1/PART1_REPORT.md
- deliverables/part2/PART2_REPORT.md
- deliverables/part3/PART3_REPORT.md

✅ **SLURM Scripts:**
- deliverables/part1/heat_job.slurm
- deliverables/part2/heat_gpu_job.slurm

✅ **Sample Data:**
- deliverables/part3/heat_output.vtk

❌ **Excluded (by .gitignore):**
- Compiled binaries (*.o, *.out, *.exe)
- Python cache (__pycache__/)
- Virtual environments (.venv/)
- Output files (*.txt, *.log)
- IDE files (.vscode/)

---

## Repository Features to Enable

After creating the repository, consider enabling:

### 1. GitHub Pages (for documentation)

```yaml
# Settings → Pages → Source: Deploy from branch → main → /docs
```

### 2. Topics (for discoverability)

Add these topics to your repository:
- `high-performance-computing`
- `hpc`
- `mpi`
- `openmp`
- `cuda`
- `gpu-computing`
- `parallel-programming`
- `heat-equation`
- `scientific-computing`
- `vtk`

### 3. About Section

**Description:**
```
High-Performance Computing implementation of 2D heat equation solver featuring MPI+OpenMP hybrid parallelization (18.70× speedup), CUDA GPU acceleration (20.94× speedup), and VTK visualization
```

**Website:** (if you set up GitHub Pages)
```
https://yourusername.github.io/heat-equation-hpc/
```

---

## Sharing the Repository

Once published, share using:

**Direct Link:**
```
https://github.com/yourusername/heat-equation-hpc
```

**Clone Command for Others:**
```bash
git clone https://github.com/yourusername/heat-equation-hpc.git
```

**Badge for Your Website/Portfolio:**
```markdown
[![GitHub](https://img.shields.io/badge/GitHub-heat--equation--hpc-blue?logo=github)](https://github.com/yourusername/heat-equation-hpc)
```

---

## Maintenance Tips

### Update Repository

```powershell
# After making changes
git add .
git commit -m "Description of changes"
git push
```

### Create Release

After major milestones:

1. Go to **Releases** → **Create a new release**
2. Tag: `v1.0.0`
3. Title: `Initial Release - Complete HPC Implementation`
4. Description: Summarize features and performance results
5. Click **Publish release**

### Add Collaborators

**Settings → Collaborators → Add people**

---

## Troubleshooting

### Issue: Large files rejected

If any file is > 100 MB:
```powershell
# Use Git LFS
git lfs install
git lfs track "*.vtk"
git add .gitattributes
git commit -m "Add Git LFS for large files"
```

### Issue: Authentication failed

Use GitHub Personal Access Token:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select `repo` scope
4. Use token as password when pushing

### Issue: OneDrive sync conflicts

Temporarily pause OneDrive during git operations:
- Right-click OneDrive icon → Pause syncing

---

## Security Notes

⚠️ **Important:** The deliverables contain cluster credentials (user51/passwd). 

**Before making repository public, either:**

1. **Remove credentials from SLURM scripts:**
   ```bash
   # In heat_job.slurm, change:
   #SBATCH --account=user51
   # To:
   #SBATCH --account=YOUR_USERNAME
   ```

2. **Or keep repository private** and share only with trusted collaborators

3. **Or create a sanitized branch for public sharing:**
   ```powershell
   git checkout -b public
   # Edit files to remove credentials
   git add .
   git commit -m "Sanitize credentials for public release"
   git push -u origin public
   ```

---

## Next Steps

After setting up the repository:

1. ✅ Add repository description and topics
2. ✅ Create initial release (v1.0.0)
3. ✅ Add badges to README (build status, license, etc.)
4. ✅ Consider adding GitHub Actions for CI/CD
5. ✅ Share link with classmates/colleagues
6. ✅ Add to your portfolio/resume

---

**Ready to share your HPC work with the world! 🚀**
