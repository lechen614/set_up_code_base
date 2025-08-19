# Code Base Setup Script (PowerShell)

Automates Git repository cloning, patch installation, and development environment setup using PowerShell.

## Features

- **Repository Management**: Detects existing repositories and prompts for updates.
- **Patch Installation**: Automatically applies development and test patches after cloning.
- **Directory Structure**: Creates organized directory structure automatically.
- **Progress Tracking**: Shows detailed progress and summary statistics.
- **Error Handling**: Clear error messages with diagnostic information.
- **Named Parameters**: Clean parameter parsing with validation.

## Structure

```
Target Folder/
├── test/           # junzhu64/test
├── doc/            # junzhu64/doc
└── dev/
    ├── CIMSpy/     # junzhu64/CIMSpy
    ├── UMLTool/    # junzhu64/UMLTool
    ├── M3Admin/    # junzhu64/M3Admin
    └── CIMExporter/# junzhu64/CIMExporter
```

## Usage

```powershell
.\set_up_code_base.ps1 -SourceFolder <source_folder> [-TargetFolder <target_folder>]
```

**Parameters:**
- `-SourceFolder` - Required. The PI-Shared folder path.
- `-TargetFolder` - Optional. Target folder (defaults to current directory).

**Examples:**
```powershell
.\set_up_code_base.ps1 -SourceFolder "C:\Users\username\OneDrive - POWER INFO LLC\PI-Shared"
.\set_up_code_base.ps1 -SourceFolder "C:\Users\username\OneDrive - POWER INFO LLC\PI-Shared" -TargetFolder "D:\projects"
```

## How It Works

### Phase 1: Repository Cloning (`clone_repos.ps1`)
1. **Setup**: Validates parameters and creates directory structure.
2. **Repository Processing**: For each repository:
   - If exists: prompts to pull latest changes.
   - If new: clones from GitHub.
3. **Summary**: Shows cloned/updated/skipped/failed counts.

### Phase 2: Copy from PI-Shared (`copy_from_PI-Shared.ps1`)
1. **Copying**: Copies specified folders from the source `PI-Shared` directory.
2. **Prompts**: Asks for confirmation before overwriting existing directories.
3. **Summary**: Reports on copied, skipped, and failed operations.

### Phase 3: Patch Installation (`patch-installation.ps1`)
1. **Dev Patching**: Copies development patches (e.g., `RawDataService.cs`).
2. **Library Management**: Updates Python/C++ libraries and cleans old versions.
3. **Test Data**: Applies test patches (models, configurations, sample data).
4. **Results**: Shows success/failure counts with detailed error diagnostics.

## Prerequisites

- Git installed and in PATH
- PowerShell
- Network access to GitHub
- Windows environment

## Files

- **`set_up_code_base.ps1`** - Main entry point with parameter parsing.
- **`clone_repos.ps1`** - Repository cloning module.
- **`copy_from_PI-Shared.ps1`** - Module for copying from the PI-Shared folder.
- **`patch-installation.ps1`** - Patch application module.

## Troubleshooting

### Repository Issues
- **"Git is not recognized"**: Add Git to your system's PATH environment variable.
- **Clone failures**: Check network connection and repository access.
- **Source folder errors**: Verify the `-SourceFolder` path exists.

### Patch Issues
- **"Source file missing"**: Check if the required `3rd-party` subdirectories exist in the PI-Shared folder.
- **"Destination directory not found"**: Ensure repositories were cloned successfully first.
