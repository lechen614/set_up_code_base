param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFolder,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetFolder = (Get-Location).Path
)

# ========================================================================
# Copy from PI-Shared Module - PowerShell Version
# ========================================================================
# This PowerShell script handles copying files from the PI-Shared OneDrive folder
# with proper error handling and progress reporting.
# ========================================================================

Write-Host ""
Write-Host "========================================================================"
Write-Host "COPY FROM PI-SHARED MODULE - POWERSHELL VERSION"
Write-Host "========================================================================"
Write-Host "Source folder: $SourceFolder"
Write-Host "Target folder: $TargetFolder"
Write-Host ""

# Validate source folder exists
if (-not (Test-Path $SourceFolder)) {
    Write-Host "ERROR: Source folder does not exist: $SourceFolder" -ForegroundColor Red
    exit 1
}

# Initialize counters
$copiedCount = 0
$skippedCount = 0
$errorCount = 0

# Define copy pairs
$copyPairs = @(
    @{ Source = "Github\Models\TestModels"; Target = "test\TestModels" }
    @{ Source = "Github\Models\TestCases"; Target = "test\TestCases" }
    @{ Source = "Github\Guides"; Target = "doc\Guides" }
    @{ Source = "Github\Projects\AEP"; Target = "test\CIMSpy\Customization\AEP" }
    @{ Source = "Github\Projects\Oncor"; Target = "test\CIMSpy\Customization\Oncor" }
    @{ Source = "Github\Projects\CPS"; Target = "test\CIMSpy\Customization\CPS" }
    @{ Source = "3rd-party"; Target = "3rd-party" }
    @{ Source = "Presentations"; Target = "doc\Presentations" }
)

Write-Host "Processing $($copyPairs.Count) copy operations..."
Write-Host ""

# Process each copy pair
for ($i = 0; $i -lt $copyPairs.Count; $i++) {
    $pair = $copyPairs[$i]
    $sourceRel = $pair.Source
    $targetRel = $pair.Target
    $opNum = $i + 1
    
    Write-Host "[$opNum/$($copyPairs.Count)] $sourceRel to $targetRel"
    
    # Build full paths
    $fullSource = Join-Path $SourceFolder $sourceRel
    $fullTarget = Join-Path $TargetFolder $targetRel
    
    # Check if source exists
    if (-not (Test-Path $fullSource)) {
        Write-Host "  ERROR: Source folder does not exist: $fullSource" -ForegroundColor Red
        $errorCount++
        continue
    }
    
    # Handle existing target
    if (Test-Path $fullTarget) {
        Write-Host "  WARNING: Target folder already exists: $fullTarget" -ForegroundColor Yellow
        $overwrite = Read-Host "  Overwrite? (y/n)"
        if ($overwrite -ne "y" -and $overwrite -ne "Y") {
            Write-Host "  Skipped" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        Write-Host "  Removing existing target folder..."
        try {
            Remove-Item $fullTarget -Recurse -Force -ErrorAction Stop
        }
        catch {
            Write-Host "  ERROR: Failed to remove existing target folder: $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
            continue
        }
    }
    
    # Create target directory structure if needed
    $targetParent = Split-Path $fullTarget -Parent
    if (-not (Test-Path $targetParent)) {
        Write-Host "  Creating target directory structure..."
        try {
            New-Item -Path $targetParent -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host "  ERROR: Failed to create target directory: $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
            continue
        }
    }
    
    # Copy the folder
    Write-Host "  Copying folder and contents..."
    try {
        Copy-Item $fullSource $fullTarget -Recurse -Force -ErrorAction Stop
        Write-Host "  Successfully copied" -ForegroundColor Green
        $copiedCount++
    }
    catch {
        Write-Host "  ERROR: Copy operation failed: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "========================================================================"
Write-Host "COPY SUMMARY"
Write-Host "========================================================================"
Write-Host "Copied: $copiedCount folders" -ForegroundColor Green
Write-Host "Skipped: $skippedCount folders" -ForegroundColor Yellow
Write-Host "Errors: $errorCount folders" -ForegroundColor Red
Write-Host "========================================================================"

if ($errorCount -gt 0) {
    Write-Host "WARNING: Some copy operations failed" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All copy operations completed successfully" -ForegroundColor Green
    exit 0
}
