@echo off
setlocal enabledelayedexpansion

REM ========================================================================
REM Repository Cloning Module
REM ========================================================================
REM This module handles cloning and updating of all project repositories.
REM It contains the repository configuration and Git operations logic.
REM
REM USAGE:
REM   call clone_repos.bat <target_folder>
REM
REM PARAMETERS:
REM   %1 - Target folder where repositories will be cloned
REM ========================================================================

set TARGET_FOLDER=%1
set "cloned_count=0"
set "updated_count=0"
set "skipped_count=0"
set "failed_count=0"

if "%TARGET_FOLDER%"=="" (
    echo ERROR: Target folder parameter is required.
    echo USAGE: clone_repos.bat ^<target_folder^>
    exit /b 1
)

REM ========================================================================
REM REPOSITORY CONFIGURATION
REM ========================================================================
REM All repository URLs and their target directory structure

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

echo ========================================
echo REPOSITORY CLONING MODULE
echo ========================================
echo Target folder: %TARGET_FOLDER%
echo.

REM Create target directory if it doesn't exist
if not exist "%TARGET_FOLDER%" mkdir "%TARGET_FOLDER%"

REM Create dev directory under target folder if it doesn't exist
if not exist "%TARGET_FOLDER%\dev" mkdir "%TARGET_FOLDER%\dev"

echo Processing 6 repositories...

REM Process each repository
call :ProcessRepo %REPO1_URL% %REPO1_DIR% 1
if !errorlevel! neq 0 exit /b 1

call :ProcessRepo %REPO2_URL% %REPO2_DIR% 2
if !errorlevel! neq 0 exit /b 1

call :ProcessRepo %REPO3_URL% %REPO3_DIR% 3
if !errorlevel! neq 0 exit /b 1

call :ProcessRepo %REPO4_URL% %REPO4_DIR% 4
if !errorlevel! neq 0 exit /b 1

call :ProcessRepo %REPO5_URL% %REPO5_DIR% 5
if !errorlevel! neq 0 exit /b 1

call :ProcessRepo %REPO6_URL% %REPO6_DIR% 6
if !errorlevel! neq 0 exit /b 1

echo.
echo ========================================
echo REPOSITORY CLONING SUMMARY
echo ========================================
echo Cloned: !cloned_count! repositories
echo Updated: !updated_count! repositories  
echo Skipped: !skipped_count! repositories
echo Failed: !failed_count! repositories
echo.
if !failed_count! gtr 0 (
    echo WARNING: Some repositories failed to process
    echo ========================================
    exit /b 1
) else (
    echo All repositories processed successfully
    echo ========================================
    exit /b 0
)

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

echo.
echo [%REPO_NUM%/6] Processing %REPO_NAME%...

REM Check if the repository directory already exists
if exist "%REPO_DIR%" (
    call :handle_existing_repo
) else (
    call :handle_new_repo
)

echo.
exit /b 0

REM ========================================================================
REM FUNCTION: Handle Existing Repository
REM ========================================================================
REM Prompts user to pull latest changes for existing repositories
REM ========================================================================
:handle_existing_repo
echo %REPO_NAME%: Repository exists
set /p PULL_CHOICE="Pull latest changes? (y/n): "
if /i "!PULL_CHOICE!"=="y" (
    echo Pulling latest changes...
    call :pull_changes
) else (
    echo %REPO_NAME%: Skipped
    set /a skipped_count+=1
)
goto :eof

REM ========================================================================
REM FUNCTION: Handle New Repository
REM ========================================================================
REM Clones a new repository
REM ========================================================================
:handle_new_repo
echo Cloning %REPO_NAME%...
git clone %REPO_URL% "%REPO_DIR%" >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Failed to clone %REPO_NAME%
    echo   URL: %REPO_URL%
    echo   Target: %REPO_DIR%
    set /a failed_count+=1
    exit /b 1
)
echo %REPO_NAME%: Cloned successfully
set /a cloned_count+=1
goto :eof

REM ========================================================================
REM FUNCTION: Pull Changes
REM ========================================================================
REM Pulls latest changes from the remote repository
REM ========================================================================
:pull_changes
REM Change to repo directory, pull changes, then return to target folder
cd /d "%REPO_DIR%" && git pull >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Failed to pull %REPO_NAME%
    echo   Directory: %REPO_DIR%
    set /a failed_count+=1
) else (
    echo %REPO_NAME%: Updated successfully
    set /a updated_count+=1
)

REM Return to target folder
cd /d "%TARGET_FOLDER%"
goto :eof