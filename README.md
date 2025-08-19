# Code Base Setup Script

Automates Git repository cloning, patch installation, and development environment setup.

## Features

- **Repository Management**: Detects existing repositories and prompts for updates
- **Patch Installation**: Automatically applies development and test patches after cloning
- **Directory Structure**: Creates organized directory structure automatically  
- **Progress Tracking**: Shows detailed progress and summary statistics
- **Error Handling**: Clear error messages with diagnostic information
- **Named Parameters**: Clean parameter parsing with validation

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

```batch
set_up_code_base.bat -source <source_folder> [-target <target_folder>]
```

**Parameters:**
- `-source` - Required. Source folder with repository configs
- `-target` - Optional. Target folder (defaults to current directory)

**Examples:**
```batch
set_up_code_base.bat -source C:\configs
set_up_code_base.bat -source C:\configs -target D:\projects
```

## How It Works

### Phase 1: Repository Cloning (`clone_repos.bat`)
1. **Setup**: Validates parameters and creates directory structure
2. **Repository Processing**: For each of 6 repositories:
   - If exists: prompts to pull latest changes
   - If new: clones from GitHub
3. **Summary**: Shows cloned/updated/skipped/failed counts

### Phase 2: Patch Installation (`patch-installation_revised.bat`)
1. **Dev Patching**: Copies development patches (RawDataService.cs)
2. **Library Management**: Updates Python/C++ libraries and cleans old versions
3. **Test Data**: Applies test patches (models, configurations, sample data)
4. **Results**: Shows success/failure counts with detailed error diagnostics

## Output Example

```
========================================
REPOSITORY CLONING MODULE
========================================
[1/6] Processing test...
test: Updated successfully
...
========================================
REPOSITORY CLONING SUMMARY
========================================
Cloned: 2 repositories
Updated: 3 repositories
Skipped: 1 repositories
Failed: 0 repositories

========================================
PATCH INSTALLATION SCRIPT
========================================
[1/3] Patching dev files...
RawDataService.cs patched successfully
[2/3] Copying libraries to test...
Libraries copied to release-desktop: OK
[3/3] Patching test directories...
Test patches applied: 10 successful, 2 failed
========================================
```

## Prerequisites

- Git installed and in PATH
- Network access to GitHub  
- Windows environment
- Required directory structure:
  ```
  3rd-party/
  ├── dev-patch/          # Development patches
  ├── test-patch/         # Test data and configurations
  └── lib/c++/           # C++ libraries for deployment
  ```

## Files

- **`set_up_code_base.bat`** - Main entry point with parameter parsing
- **`clone_repos.bat`** - Repository cloning module with progress tracking
- **`patch-installation_revised.bat`** - Patch application with detailed diagnostics

## Troubleshooting

### Repository Issues
- **"Git is not recognized"**: Add Git to PATH environment variable
- **Clone failures**: Check network connection and repository access
- **Source folder errors**: Verify folder path exists

### Patch Issues
- **"Source file missing"**: Check if `3rd-party/dev-patch/` and `3rd-party/test-patch/` exist
- **"Destination directory not found"**: Ensure repositories were cloned successfully first
- **Library copy failures**: Verify `3rd-party/lib/c++/` contains required DLL files

### Expected Warnings
- `TestModels` and `TestCases` "source not found" - These directories may not exist in all setups
- Old Python library cleanup messages - Normal when upgrading library versions
