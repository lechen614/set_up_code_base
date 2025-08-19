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

echo Starting repository cloning process...
echo Target folder: %TARGET_FOLDER%
echo.

REM Create target directory if it doesn't exist
if not exist "%TARGET_FOLDER%" mkdir "%TARGET_FOLDER%"

REM Create dev directory under target folder if it doesn't exist
if not exist "%TARGET_FOLDER%\dev" mkdir "%TARGET_FOLDER%\dev"

echo Processing 6 repositories...
echo.

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
echo All repositories have been cloned or updated to the latest.
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
echo Repository already exists: %REPO_DIR%
set /p PULL_CHOICE="Pull latest changes? (y/n): "
if /i "!PULL_CHOICE!"=="y" (
    echo Pulling latest changes...
    call :pull_changes
) else (
    echo Skipping %REPO_NAME%.
)
goto :eof

REM ========================================================================
REM FUNCTION: Handle New Repository
REM ========================================================================
REM Clones a new repository
REM ========================================================================
:handle_new_repo
echo Cloning %REPO_NAME%...
git clone %REPO_URL% "%REPO_DIR%"
if !errorlevel! neq 0 (
    echo ERROR: Failed to clone %REPO_NAME%. Aborting.
    exit /b 1
)
echo Successfully cloned %REPO_NAME%.
goto :eof

REM ========================================================================
REM FUNCTION: Pull Changes
REM ========================================================================
REM Pulls latest changes from the remote repository
REM ========================================================================
:pull_changes
REM Change to repo directory, pull changes, then return to target folder
cd /d "%REPO_DIR%" && git pull
if !errorlevel! neq 0 (
    echo ERROR: Failed to pull %REPO_NAME%. Continuing...
) else (
    echo Successfully updated %REPO_NAME%.
)

REM Return to target folder
cd /d "%TARGET_FOLDER%"
goto :eof