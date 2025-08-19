# ========================================================================
# Patch Installation Script - PowerShell Version
# ========================================================================
# This script applies patches to the development and test directories
# after repositories have been cloned and files copied from PI-Shared.
# ========================================================================

# ========================================================================
# FUNCTION DEFINITIONS
# ========================================================================

# ========================================================================
# FUNCTION: CopyWithCheck
# ========================================================================
# Copies a directory with error checking and reporting
# ========================================================================
function CopyWithCheck {
	param(
		[string]$Source,
		[string]$Target,
		[string]$Name
	)
	
	if (Test-Path $Source) {
		try {
			# Create target directory if it doesn't exist
			$targetParent = Split-Path $Target -Parent
			if ($targetParent -and (-not (Test-Path $targetParent))) {
				New-Item -Path $targetParent -ItemType Directory -Force -ErrorAction Stop | Out-Null
			}
			
			# Copy the directory
			Copy-Item $Source $Target -Recurse -Force -ErrorAction Stop
			Write-Host "$Name`: OK" -ForegroundColor Green
			$script:successCount++
		}
		catch {
			Write-Host "ERROR: $Name copy failed" -ForegroundColor Red
			Write-Host "  Source: $Source" -ForegroundColor Red
			Write-Host "  Target: $Target" -ForegroundColor Red
			Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
			$script:failedCount++
		}
	} else {
		Write-Host "ERROR: $Name source not found" -ForegroundColor Red
		Write-Host "  Missing: $Source" -ForegroundColor Red
		$script:failedCount++
	}
}

# ========================================================================
# MAIN SCRIPT EXECUTION
# ========================================================================

Write-Host "========================================"
Write-Host "PATCH INSTALLATION SCRIPT"
Write-Host "========================================"

# Initialize counters
$script:successCount = 0
$script:failedCount = 0
$script:cleanupCount = 0

# ========================================================================
# STEP 1: PATCH DEV FILES
# ========================================================================

Write-Host ""
Write-Host "[1/3] Patching dev files..."

$sourceFile = "3rd-party\dev-patch\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs"
$targetDir = "dev\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\"
$targetFile = Join-Path $targetDir "RawDataService.cs"

if (Test-Path $sourceFile) {
	if (Test-Path $targetDir) {
		try {
			Copy-Item $sourceFile $targetFile -Force -ErrorAction Stop
			Write-Host "RawDataService.cs patched successfully" -ForegroundColor Green
		}
		catch {
			Write-Host "ERROR: Failed to copy RawDataService.cs" -ForegroundColor Red
			Write-Host "  Source: $sourceFile" -ForegroundColor Red
			Write-Host "  Target: $targetFile" -ForegroundColor Red
			Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
		}
	} else {
		Write-Host "ERROR: Destination directory not found" -ForegroundColor Red
		Write-Host "  Missing: $targetDir" -ForegroundColor Red
		Write-Host "  Make sure repositories are cloned properly" -ForegroundColor Red
	}
} else {
	Write-Host "ERROR: Source file not found" -ForegroundColor Red
	Write-Host "  Missing: $sourceFile" -ForegroundColor Red
	Write-Host "  Check if dev-patch directory exists" -ForegroundColor Red
}

# ========================================================================
# CLEANUP OLD PYTHON LIBRARIES
# ========================================================================

Write-Host ""
Write-Host "Cleaning up old Python libraries..."

# Remove powerflow directory
$powerflowDir = "test\CIMSpy\powerflow"
if (Test-Path $powerflowDir) {
	try {
		Remove-Item $powerflowDir -Recurse -Force -ErrorAction Stop
		Write-Host "Removed old powerflow directory" -ForegroundColor Green
	}
	catch {
		Write-Host "WARNING: Could not remove powerflow directory: $($_.Exception.Message)" -ForegroundColor Yellow
	}
}

# Define files to clean up
$filesToCleanup = @(
	"test\CIMSpy\release-desktop\boost_python313-vc142-mt-x64-1_87.dll",
	"test\CIMSpy\debug-server\boost_python313-vc142-mt-x64-1_87.dll",
	"test\CIMSpy\release-desktop\python313.dll",
	"test\CIMSpy\debug-server\python313.dll"
)

foreach ($file in $filesToCleanup) {
	if (Test-Path $file) {
		try {
			Remove-Item $file -Force -ErrorAction Stop
			$script:cleanupCount++
		}
		catch {
			Write-Host "WARNING: Could not remove $file`: $($_.Exception.Message)" -ForegroundColor Yellow
		}
	}
}

Write-Host "Cleaned up $script:cleanupCount old Python library files"

# ========================================================================
# STEP 2: COPY LIBRARIES TO TEST
# ========================================================================

Write-Host ""
Write-Host "[2/3] Copying libraries to test..."

$libSource = "3rd-party\lib\c++"
if (Test-Path $libSource) {
	# Copy to release-desktop
	$releaseTarget = "test\CIMSpy\release-desktop"
	try {
		if (Test-Path $releaseTarget) {
			Copy-Item "$libSource\*" $releaseTarget -Recurse -Force -ErrorAction Stop
			$releaseStatus = "OK"
			Write-Host "Libraries copied to release-desktop: OK" -ForegroundColor Green
		} else {
			$releaseStatus = "FAILED - Target directory not found"
			Write-Host "Libraries copied to release-desktop: FAILED - Target directory not found" -ForegroundColor Red
		}
	}
	catch {
		$releaseStatus = "FAILED"
		Write-Host "Libraries copied to release-desktop: FAILED" -ForegroundColor Red
		Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
	}
	
	# Copy to debug-server
	$debugTarget = "test\CIMSpy\debug-server"
	try {
		if (Test-Path $debugTarget) {
			Copy-Item "$libSource\*" $debugTarget -Recurse -Force -ErrorAction Stop
			$debugStatus = "OK"
			Write-Host "Libraries copied to debug-server: OK" -ForegroundColor Green
		} else {
			$debugStatus = "FAILED - Target directory not found"
			Write-Host "Libraries copied to debug-server: FAILED - Target directory not found" -ForegroundColor Red
		}
	}
	catch {
		$debugStatus = "FAILED"
		Write-Host "Libraries copied to debug-server: FAILED" -ForegroundColor Red
		Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
	}
	
	if ($releaseStatus -eq "FAILED") {
		Write-Host "ERROR: Failed to copy libraries to release-desktop" -ForegroundColor Red
		Write-Host "  Source: $libSource" -ForegroundColor Red
		Write-Host "  Target: $releaseTarget" -ForegroundColor Red
	}
	if ($debugStatus -eq "FAILED") {
		Write-Host "ERROR: Failed to copy libraries to debug-server" -ForegroundColor Red
		Write-Host "  Source: $libSource" -ForegroundColor Red
		Write-Host "  Target: $debugTarget" -ForegroundColor Red
	}
} else {
	Write-Host "ERROR: Source library directory not found" -ForegroundColor Red
	Write-Host "  Missing: $libSource" -ForegroundColor Red
	Write-Host "  Check if 3rd-party directory structure is correct" -ForegroundColor Red
}

# ========================================================================
# STEP 3: PATCH TEST DIRECTORIES
# ========================================================================

Write-Host ""
Write-Host "[3/3] Patching test directories..."

# Define copy operations
$copyOperations = @(
	@{ Source = "3rd-party\test-patch\TestModels"; Target = "test\TestModels"; Name = "TestModels" },
	@{ Source = "3rd-party\test-patch\TestCases"; Target = "test\TestCases"; Name = "TestCases" },
	@{ Source = "3rd-party\test-patch\CIMSpy\powerflow"; Target = "test\CIMSpy\powerflow"; Name = "CIMSpy powerflow" },
	@{ Source = "3rd-party\test-patch\CIMSpy\ModelDepositories"; Target = "test\CIMSpy\ModelDepositories"; Name = "CIMSpy ModelDepositories" },
	@{ Source = "3rd-party\test-patch\CIMSpy\export"; Target = "test\CIMSpy\export"; Name = "CIMSpy export" },
	@{ Source = "3rd-party\test-patch\CIMSpy\log"; Target = "test\CIMSpy\log"; Name = "CIMSpy log" },
	@{ Source = "3rd-party\test-patch\CIMSpy\temp"; Target = "test\CIMSpy\temp"; Name = "CIMSpy temp" },
	@{ Source = "3rd-party\test-patch\CIMSpy\data"; Target = "test\CIMSpy\data"; Name = "CIMSpy data" },
	@{ Source = "3rd-party\test-patch\CIMExporter\csv"; Target = "test\CIMExporter\csv"; Name = "CIMExporter csv" },
	@{ Source = "3rd-party\test-patch\CIMExporter\log"; Target = "test\CIMExporter\log"; Name = "CIMExporter log" },
	@{ Source = "3rd-party\test-patch\CIMExporter\mrid"; Target = "test\CIMExporter\mrid"; Name = "CIMExporter mrid" },
	@{ Source = "3rd-party\test-patch\CIMExporter\cimxml"; Target = "test\CIMExporter\cimxml"; Name = "CIMExporter cimxml" }
)

foreach ($operation in $copyOperations) {
	CopyWithCheck -Source $operation.Source -Target $operation.Target -Name $operation.Name
}

Write-Host ""
Write-Host "Test patches applied: $script:successCount successful, $script:failedCount failed"
Write-Host ""
Write-Host "========================================"
Write-Host "PATCH INSTALLATION COMPLETED"
Write-Host "========================================"

# Exit with appropriate code
if ($script:failedCount -gt 0) {
	exit 1
} else {
	exit 0
}


