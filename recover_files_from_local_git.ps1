# ========================================================================
# File Recovery from Local Git Repositories - PowerShell Version
# ========================================================================
# This script recovers files from local git repositories by resetting them
# to their HEAD state. It handles both regular repositories and bare repositories
# with custom git directories.
#
# USAGE:
#   .\recover_files_from_local_git.ps1
#
# This script should be run as Step 3 in the setup process, after repository
# cloning and before patch installation.
# ========================================================================

# Initialize counters
$script:successCount = 0
$script:failedCount = 0

# ========================================================================
# FUNCTION DEFINITIONS
# ========================================================================

# ========================================================================
# FUNCTION: RecoverRegularRepo
# ========================================================================
# Recovers files from a regular git repository using standard .git directory
# ========================================================================
function RecoverRegularRepo {
    param(
        [string]$RepoPath,
        [string]$RepoName
    )
    
    Write-Host "Processing $RepoName..."
    
    if (-not (Test-Path $RepoPath)) {
        Write-Host "ERROR: Repository path not found: $RepoPath" -ForegroundColor Red
        $script:failedCount++
        return
    }
    
    $gitDir = Join-Path $RepoPath ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Host "ERROR: Not a git repository: $RepoPath" -ForegroundColor Red
        $script:failedCount++
        return
    }
    
    $currentLocation = Get-Location
    
    try {
        Set-Location $RepoPath
        
        # Execute git reset --hard HEAD
        git reset --hard HEAD | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$RepoName`: Files recovered successfully" -ForegroundColor Green
            $script:successCount++
        } else {
            Write-Host "ERROR: Failed to reset $RepoName" -ForegroundColor Red
            Write-Host "  Path: $RepoPath" -ForegroundColor Red
            $script:failedCount++
        }
    }
    catch {
        Write-Host "ERROR: Failed to process $RepoName" -ForegroundColor Red
        Write-Host "  Path: $RepoPath" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedCount++
    }
    finally {
        Set-Location $currentLocation
    }
}

# ========================================================================
# FUNCTION: RecoverBareRepo
# ========================================================================
# Recovers files from a bare repository using custom git directory
# ========================================================================
function RecoverBareRepo {
    param(
        [string]$WorkTreePath,
        [string]$GitDirName,
        [string]$RepoName
    )
    
    Write-Host "Processing $RepoName (bare repository)..."
    
    if (-not (Test-Path $WorkTreePath)) {
        Write-Host "ERROR: Work tree path not found: $WorkTreePath" -ForegroundColor Red
        $script:failedCount++
        return
    }
    
    $gitDir = Join-Path $WorkTreePath $GitDirName
    if (-not (Test-Path $gitDir)) {
        Write-Host "ERROR: Git directory not found: $gitDir" -ForegroundColor Red
        $script:failedCount++
        return
    }
    
    $currentLocation = Get-Location
    
    try {
        Set-Location $WorkTreePath
        
        # Execute git reset --hard HEAD with custom git-dir and work-tree
        git --git-dir=$GitDirName --work-tree=. reset --hard HEAD | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$RepoName`: Files recovered successfully" -ForegroundColor Green
            $script:successCount++
        } else {
            Write-Host "ERROR: Failed to reset $RepoName" -ForegroundColor Red
            Write-Host "  Work tree: $WorkTreePath" -ForegroundColor Red
            Write-Host "  Git dir: $GitDirName" -ForegroundColor Red
            $script:failedCount++
        }
    }
    catch {
        Write-Host "ERROR: Failed to process $RepoName" -ForegroundColor Red
        Write-Host "  Work tree: $WorkTreePath" -ForegroundColor Red
        Write-Host "  Git dir: $GitDirName" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedCount++
    }
    finally {
        Set-Location $currentLocation
    }
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

Write-Host "========================================"
Write-Host "FILE RECOVERY FROM LOCAL GIT REPOSITORIES"
Write-Host "========================================"
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

Write-Host "[1/2] Recovering files from regular local repositories..."
Write-Host ""

# ========================================================================
# REGULAR REPOSITORIES
# ========================================================================
# These repositories use the standard .git directory structure

$regularRepos = @(
    @{ Path = "doc\Guides"; Name = "doc/Guides" },
    @{ Path = "test\TestCases"; Name = "test/TestCases" },
    @{ Path = "test\TestModels"; Name = "test/TestModels" }
)

foreach ($repo in $regularRepos) {
    RecoverRegularRepo -RepoPath $repo.Path -RepoName $repo.Name
}

Write-Host ""
Write-Host "[2/2] Recovering files from bare repositories..."
Write-Host ""

# ========================================================================
# BARE REPOSITORIES
# ========================================================================
# These repositories use custom git directories (bare repositories)

$bareRepos = @(
    @{ WorkTree = "test\CIMSpy\Customization\AEP"; GitDir = "AEPConfig.git"; Name = "AEP Configuration" },
    @{ WorkTree = "test\CIMSpy\Customization\CPS"; GitDir = "CPSConfig.git"; Name = "CPS Configuration" },
    @{ WorkTree = "test\CIMSpy\Customization\Oncor"; GitDir = "OncorConfig.git"; Name = "Oncor Configuration" }
)

foreach ($repo in $bareRepos) {
    RecoverBareRepo -WorkTreePath $repo.WorkTree -GitDirName $repo.GitDir -RepoName $repo.Name
}

Write-Host ""
Write-Host "========================================"
Write-Host "FILE RECOVERY SUMMARY"
Write-Host "========================================"
Write-Host "Successfully recovered: $script:successCount repositories" -ForegroundColor Green
Write-Host "Failed to recover: $script:failedCount repositories" -ForegroundColor Red
Write-Host ""

if ($script:failedCount -gt 0) {
    Write-Host "WARNING: Some repositories failed to recover" -ForegroundColor Red
    Write-Host "========================================"
    exit 1
} else {
    Write-Host "All repositories recovered successfully" -ForegroundColor Green
    Write-Host "========================================"
    exit 0
}
