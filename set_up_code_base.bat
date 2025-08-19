@echo off
setlocal enabledelayedexpansion

REM ========================================================================
REM Code Base Setup Script
REM ========================================================================
REM This script sets up a complete development environment by cloning
REM multiple Git repositories to their designated locations.
REM 
REM USAGE:
REM   set_up_code_base.bat -source <source_folder> [-target <target_folder>]
REM 
REM PARAMETERS:
REM   -source <folder>  - Required. The source folder for future operations
REM   -target <folder>  - Optional. Target folder for cloning repos. 
REM                       If not provided, uses current directory.
REM
REM STRUCTURE:
REM   Target folder: test, doc repositories
REM   Target/dev/ folder: CIMSpy, UMLTool, M3Admin, CIMExporter repositories
REM
REM FEATURES:
REM   - Checks if repositories already exist locally
REM   - Prompts user to pull latest changes for existing repos
REM   - Creates necessary directories automatically
REM   - Handles errors gracefully with clear messages
REM   - Uses modular clone_repos.bat for repository operations
REM ========================================================================

REM ========================================================================
REM PARAMETER PARSING
REM ========================================================================
REM Initialize variables
set SOURCE_FOLDER=
set TARGET_FOLDER=

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :validate_args
if /i "%~1"=="-source" (
    set SOURCE_FOLDER=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-target" (
    set TARGET_FOLDER=%~2
    shift
    shift
    goto :parse_args
)
REM Unknown parameter
echo ERROR: Unknown parameter: %~1
echo.
goto :show_usage

:validate_args
REM Check if source folder parameter is provided
if "%SOURCE_FOLDER%"=="" (
    echo ERROR: -source parameter is required.
    echo.
    goto :show_usage
)

REM Set target folder - use parameter if provided, otherwise use current directory
if "%TARGET_FOLDER%"=="" (
    set TARGET_FOLDER=%cd%
    echo Using current directory as target folder.
) else (
    echo Using specified target folder: %TARGET_FOLDER%
)

REM Validate that source folder exists
if not exist "%SOURCE_FOLDER%" (
    echo ERROR: Source folder does not exist: %SOURCE_FOLDER%
    pause
    exit /b 1
)
goto :start_setup

:show_usage
echo USAGE: %~nx0 -source ^<source_folder^> [-target ^<target_folder^>]
echo.
echo PARAMETERS:
echo   -source ^<folder^>  - Required. The source folder for future operations
echo   -target ^<folder^>  - Optional. Target folder for cloning repos.
echo                       If not provided, uses current directory.
echo.
echo EXAMPLES:
echo   %~nx0 -source C:\configs
echo   %~nx0 -source C:\configs -target D:\projects
pause
exit /b 1

:start_setup

echo Starting code base setup...
echo Source folder: %SOURCE_FOLDER%
echo Target folder: %TARGET_FOLDER%
echo.

REM ========================================================================
REM MAIN EXECUTION
REM ========================================================================

REM Call the repository cloning module
call clone_repos.bat "%TARGET_FOLDER%"
if !errorlevel! neq 0 goto :error_exit

REM Apply patches after successful repository cloning
echo.
echo Applying patches...
call patch-installation_revised.bat
if !errorlevel! neq 0 (
    echo WARNING: Patch installation encountered errors but continuing...
)

echo.
echo Code base setup completed.
pause
exit /b 0

:error_exit
echo.
echo Setup aborted due to error.
pause
exit /b 1
