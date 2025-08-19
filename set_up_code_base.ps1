param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFolder,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetFolder = (Get-Location).Path
)

# ========================================================================
# Code Base Setup Script - PowerShell Version
# ========================================================================
# This script sets up a complete development environment by cloning
# multiple Git repositories to their designated locations.
# 
# USAGE:
#   .\set_up_code_base.ps1 -SourceFolder <source_folder> [-TargetFolder <target_folder>]
# 
# PARAMETERS:
#   -SourceFolder <folder>  - Required. The PI-Shared folder path. This varies by device
#                            as it's under OneDrive and may contain username prefixes.
#                            Example: C:\Users\[username]\OneDrive - POWER INFO LLC\[customized_folder_name]\PI-Shared
#   -TargetFolder <folder>  - Optional. Target folder for cloning repos. 
#                            If not provided, uses current directory.
#
# STRUCTURE:
#   Target folder: test, doc repositories
#   Target/dev/ folder: CIMSpy, UMLTool, M3Admin, CIMExporter repositories
#
# FEATURES:
#   - Checks if repositories already exist locally
#   - Prompts user to pull latest changes for existing repos
#   - Creates necessary directories automatically
#   - Handles errors gracefully with clear messages
#   - Uses modular clone_repos.ps1 for repository operations
#   - Uses modular copy_from_PI-Shared.ps1 for copying from PI-Shared folder
# ========================================================================

# Validate that source folder exists
if (-not (Test-Path $SourceFolder)) {
    Write-Host "ERROR: Source folder does not exist: $SourceFolder" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Display configuration
if ($TargetFolder -eq (Get-Location).Path) {
    Write-Host "Using current directory as target folder."
} else {
    Write-Host "Using specified target folder: $TargetFolder"
}

Write-Host ""
Write-Host "Starting code base setup..."
Write-Host "Source folder: $SourceFolder"
Write-Host "Target folder: $TargetFolder"
Write-Host ""

# ========================================================================
# MAIN EXECUTION
# ========================================================================

try {
    # Call the repository cloning module
    Write-Host "========================================"
    Write-Host "STEP 1: CLONING REPOSITORIES"
    Write-Host "========================================"
    
    $cloneScript = Join-Path $PSScriptRoot "clone_repos.ps1"
    if (-not (Test-Path $cloneScript)) {
        throw "clone_repos.ps1 not found in the same directory as this script"
    }
    
    & $cloneScript -TargetFolder $TargetFolder
    if ($LASTEXITCODE -ne 0) {
        throw "Repository cloning failed"
    }
    
    # Copy files from PI-Shared folder
    Write-Host ""
    Write-Host "========================================"
    Write-Host "STEP 2: COPYING FROM PI-SHARED"
    Write-Host "========================================"
    
    $copyScript = Join-Path $PSScriptRoot "copy_from_PI-Shared.ps1"
    if (-not (Test-Path $copyScript)) {
        throw "copy_from_PI-Shared.ps1 not found in the same directory as this script"
    }
    
    & $copyScript -SourceFolder $SourceFolder -TargetFolder $TargetFolder
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Copy from PI-Shared encountered errors but continuing..." -ForegroundColor Yellow
    }
    
    # Apply patches after successful repository cloning and copying
    Write-Host ""
    Write-Host "========================================"
    Write-Host "STEP 3: APPLYING PATCHES"
    Write-Host "========================================"
    
    $patchScript = Join-Path $PSScriptRoot "patch-installation.ps1"
    if (-not (Test-Path $patchScript)) {
        throw "patch-installation.ps1 not found in the same directory as this script"
    }
    
    & $patchScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Patch installation encountered errors but continuing..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host "SETUP COMPLETED SUCCESSFULLY"
    Write-Host "========================================"
    Write-Host "Code base setup completed." -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit 0
}
catch {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "SETUP FAILED"
    Write-Host "========================================"
    Write-Host "Setup aborted due to error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
