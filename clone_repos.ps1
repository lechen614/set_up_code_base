param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$TargetFolder
)

# ========================================================================
# Repository Cloning Module - PowerShell Version
# ========================================================================
# This module handles cloning and updating of all project repositories.
# It contains the repository configuration and Git operations logic.
#
# USAGE:
#   .\clone_repos.ps1 <target_folder>
#
# PARAMETERS:
#   TargetFolder - Target folder where repositories will be cloned
# ========================================================================

# Initialize counters
$script:clonedCount = 0
$script:updatedCount = 0
$script:skippedCount = 0
$script:failedCount = 0

# ========================================================================
# REPOSITORY CONFIGURATION
# ========================================================================
# All repository URLs and their target directory structure

$repositories = @(
    @{ URL = "https://github.com/junzhu64/test"; Dir = "test" }
    @{ URL = "https://github.com/junzhu64/doc"; Dir = "doc" }
    @{ URL = "https://github.com/junzhu64/CIMSpy"; Dir = "dev\CIMSpy" }
    @{ URL = "https://github.com/junzhu64/UMLTool"; Dir = "dev\UMLTool" }
    @{ URL = "https://github.com/junzhu64/M3Admin"; Dir = "dev\M3Admin" }
    @{ URL = "https://github.com/junzhu64/CIMExporter"; Dir = "dev\CIMExporter" }
)

# ========================================================================
# FUNCTION DEFINITIONS
# ========================================================================

# ========================================================================
# FUNCTION: ProcessRepo
# ========================================================================
# Parameters:
#   RepoURL - Repository URL
#   RepoDir - Target directory path
#   RepoNum - Repository number (for progress display)
#   RepoName - Repository name
#   TotalRepos - Total number of repositories
#
# Logic:
#   1. Check if repository already exists locally
#   2. If exists: prompt user to pull latest changes
#   3. If not exists: clone the repository
#   4. Handle errors and provide user feedback
# ========================================================================
function ProcessRepo {
    param(
        [string]$RepoURL,
        [string]$RepoDir,
        [int]$RepoNum,
        [string]$RepoName,
        [int]$TotalRepos
    )
    
    Write-Host ""
    Write-Host "[$RepoNum/$TotalRepos] Processing $RepoName..."
    
    # Check if the repository directory already exists
    if (Test-Path $RepoDir) {
        HandleExistingRepo -RepoDir $RepoDir -RepoName $RepoName
    } else {
        HandleNewRepo -RepoURL $RepoURL -RepoDir $RepoDir -RepoName $RepoName
    }
}

# ========================================================================
# FUNCTION: Handle Existing Repository
# ========================================================================
# Prompts user to pull latest changes for existing repositories
# ========================================================================
function HandleExistingRepo {
    param(
        [string]$RepoDir,
        [string]$RepoName
    )
    
    Write-Host "$RepoName`: Repository exists"
    $pullChoice = Read-Host "Pull latest changes? (y/n)"
    
    if ($pullChoice -eq "y" -or $pullChoice -eq "Y") {
        Write-Host "Pulling latest changes..."
        PullChanges -RepoDir $RepoDir -RepoName $RepoName
    } else {
        Write-Host "$RepoName`: Skipped" -ForegroundColor Yellow
        $script:skippedCount++
    }
}

# ========================================================================
# FUNCTION: Handle New Repository
# ========================================================================
# Clones a new repository
# ========================================================================
function HandleNewRepo {
    param(
        [string]$RepoURL,
        [string]$RepoDir,
        [string]$RepoName
    )
    
    Write-Host "Cloning $RepoName..."
    
    try {
        # Use git clone with error handling - simple approach like .bat version  
        git clone $RepoURL $RepoDir | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$RepoName`: Cloned successfully" -ForegroundColor Green
            $script:clonedCount++
        } else {
            Write-Host "ERROR: Failed to clone $RepoName" -ForegroundColor Red
            Write-Host "  URL: $RepoURL" -ForegroundColor Red
            Write-Host "  Target: $RepoDir" -ForegroundColor Red
            $script:failedCount++
        }
    }
    catch {
        Write-Host "ERROR: Failed to clone $RepoName" -ForegroundColor Red
        Write-Host "  URL: $RepoURL" -ForegroundColor Red
        Write-Host "  Target: $RepoDir" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedCount++
    }
}

# ========================================================================
# FUNCTION: Pull Changes
# ========================================================================
# Pulls latest changes from the remote repository
# ========================================================================
function PullChanges {
    param(
        [string]$RepoDir,
        [string]$RepoName
    )
    
    $currentLocation = Get-Location
    
    try {
        # Change to repo directory and pull changes - simple approach like .bat version
        Set-Location $RepoDir
        git pull | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$RepoName`: Updated successfully" -ForegroundColor Green
            $script:updatedCount++
        } else {
            Write-Host "ERROR: Failed to pull $RepoName" -ForegroundColor Red
            Write-Host "  Directory: $RepoDir" -ForegroundColor Red
            $script:failedCount++
        }
    }
    catch {
        Write-Host "ERROR: Failed to pull $RepoName" -ForegroundColor Red
        Write-Host "  Directory: $RepoDir" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedCount++
    }
    finally {
        # Return to original location
        Set-Location $currentLocation
    }
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

Write-Host "========================================"
Write-Host "REPOSITORY CLONING MODULE"
Write-Host "========================================"
Write-Host "Target folder: $TargetFolder"
Write-Host ""

# Verify git is available
try {
    git --version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Git is not available on PATH" -ForegroundColor Red
        Write-Host "Please install Git and ensure it's accessible from PowerShell." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "ERROR: Git is not available on PATH" -ForegroundColor Red
    Write-Host "Please install Git and ensure it's accessible from PowerShell." -ForegroundColor Red
    exit 1
}

# Create target directory if it doesn't exist
if (-not (Test-Path $TargetFolder)) {
    try {
        New-Item -Path $TargetFolder -ItemType Directory -Force | Out-Null
        Write-Host "Created target directory: $TargetFolder"
    }
    catch {
        Write-Host "ERROR: Failed to create target directory: $TargetFolder" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Create dev directory under target folder if it doesn't exist
$devPath = Join-Path $TargetFolder "dev"
if (-not (Test-Path $devPath)) {
    try {
        New-Item -Path $devPath -ItemType Directory -Force | Out-Null
        Write-Host "Created dev directory: $devPath"
    }
    catch {
        Write-Host "ERROR: Failed to create dev directory: $devPath" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Processing $($repositories.Count) repositories..."

# Process each repository
for ($i = 0; $i -lt $repositories.Count; $i++) {
    $repo = $repositories[$i]
    $repoNum = $i + 1
    $repoDir = Join-Path $TargetFolder $repo.Dir
    $repoName = Split-Path $repo.Dir -Leaf
    
    try {
        ProcessRepo -RepoURL $repo.URL -RepoDir $repoDir -RepoNum $repoNum -RepoName $repoName -TotalRepos $repositories.Count
    }
    catch {
        Write-Host "ERROR: Failed to process repository $repoName" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedCount++
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "REPOSITORY CLONING SUMMARY"
Write-Host "========================================"
Write-Host "Cloned: $script:clonedCount repositories" -ForegroundColor Green
Write-Host "Updated: $script:updatedCount repositories" -ForegroundColor Cyan
Write-Host "Skipped: $script:skippedCount repositories" -ForegroundColor Yellow
Write-Host "Failed: $script:failedCount repositories" -ForegroundColor Red
Write-Host ""

if ($script:failedCount -gt 0) {
    Write-Host "WARNING: Some repositories failed to process" -ForegroundColor Red
    Write-Host "========================================"
    exit 1
} else {
    Write-Host "All repositories processed successfully" -ForegroundColor Green
    Write-Host "========================================"
    exit 0
}
