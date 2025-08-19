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
REM   -source <folder>  - Required. The source folder containing repository configs
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
echo   -source ^<folder^>  - Required. The source folder containing repository configs
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
REM CONFIGURATION SECTION
REM ========================================================================

REM Repository configurations (URL and target directory)
REM Target folder repositories
set REPO1_URL=https://github.com/junzhu64/test
set REPO1_DIR=%TARGET_FOLDER%\test

set REPO2_URL=https://github.com/junzhu64/doc
set REPO2_DIR=%TARGET_FOLDER%\doc

REM Development folder repositories (under target/dev/)
set REPO3_URL=https://github.com/junzhu64/CIMSpy
set REPO3_DIR=%TARGET_FOLDER%\dev\CIMSpy

set REPO4_URL=https://github.com/junzhu64/UMLTool
set REPO4_DIR=%TARGET_FOLDER%\dev\UMLTool

set REPO5_URL=https://github.com/junzhu64/M3Admin
set REPO5_DIR=%TARGET_FOLDER%\dev\M3Admin

set REPO6_URL=https://github.com/junzhu64/CIMExporter
set REPO6_DIR=%TARGET_FOLDER%\dev\CIMExporter

REM ========================================================================
REM MAIN EXECUTION
REM ========================================================================

REM Create target directory if it doesn't exist
if not exist "%TARGET_FOLDER%" mkdir "%TARGET_FOLDER%"

REM Create dev directory under target folder if it doesn't exist
if not exist "%TARGET_FOLDER%\dev" mkdir "%TARGET_FOLDER%\dev"

echo Processing 6 repositories...
echo.

REM Process each repository using the ProcessRepo function
call :ProcessRepo %REPO1_URL% %REPO1_DIR% 1
call :ProcessRepo %REPO2_URL% %REPO2_DIR% 2
call :ProcessRepo %REPO3_URL% %REPO3_DIR% 3
call :ProcessRepo %REPO4_URL% %REPO4_DIR% 4
call :ProcessRepo %REPO5_URL% %REPO5_DIR% 5
call :ProcessRepo %REPO6_URL% %REPO6_DIR% 6

echo.
echo All repositories processed successfully!
echo Code base setup completed.
pause
exit /b 0

REM ========================================================================
REM FUNCTION: ProcessRepo
REM ========================================================================
REM Parameters:
REM   %1 - Repository URL
REM   %2 - Target directory path
REM   %3 - Repository number (for progress display)
REM
REM Logic:
REM   1. Check if repository already exists locally
REM   2. If exists: prompt user to pull latest changes
REM   3. If not exists: clone the repository
REM   4. Handle errors and provide user feedback
REM ========================================================================
:ProcessRepo
set REPO_URL=%1
set REPO_DIR=%2
set REPO_NUM=%3

REM Extract repository name from the full directory path
for %%f in ("%REPO_DIR%") do set REPO_NAME=%%~nxf

echo [%REPO_NUM%/6] Processing %REPO_NAME%...

REM Check if the repository directory already exists
if exist "%REPO_DIR%" (
    echo Repository already exists: %REPO_DIR%
    set /p PULL_CHOICE="Pull latest changes? (y/n): "
    if /i "!PULL_CHOICE!"=="y" (
        echo Pulling latest changes...
        REM Change to repo directory, pull changes, then return to target folder
        cd /d "%REPO_DIR%" && git pull && cd /d "%TARGET_FOLDER%"
        if !errorlevel! neq 0 (
            echo ERROR: Failed to pull %REPO_NAME%. Continuing...
        ) else (
            echo Successfully updated %REPO_NAME%.
        )
    ) else (
        echo Skipping %REPO_NAME%.
    )
) else (
    REM Repository doesn't exist, clone it
    echo Cloning %REPO_NAME%...
    git clone %REPO_URL% "%REPO_DIR%"
    if !errorlevel! neq 0 (
        echo ERROR: Failed to clone %REPO_NAME%. Aborting.
        pause
        exit /b 1
    )
    echo Successfully cloned %REPO_NAME%.
)
echo.
goto :eof
