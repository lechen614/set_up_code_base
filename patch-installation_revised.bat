@echo off
echo ========================================
echo PATCH INSTALLATION SCRIPT
echo ========================================

echo.
echo [1/3] Patching dev files...
if exist "3rd-party\dev-patch\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs" (
    if exist "dev\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\" (
        copy 3rd-party\dev-patch\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs dev\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs >nul 2>&1
        if !errorlevel! equ 0 (
            echo RawDataService.cs patched successfully
        ) else (
            echo ERROR: Failed to copy RawDataService.cs
            echo   Source: 3rd-party\dev-patch\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs
            echo   Target: dev\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs
        )
    ) else (
        echo ERROR: Destination directory not found
        echo   Missing: dev\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\
        echo   Make sure repositories are cloned properly
    )
) else (
    echo ERROR: Source file not found
    echo   Missing: 3rd-party\dev-patch\CIMSpy\CIMSpyUI\CIMSpy\Infrastructure\Data\RawDataService.cs
    echo   Check if dev-patch directory exists
)

echo.
echo Cleaning up old Python libraries...
rmdir test\CIMSpy\powerflow /s /q 2>nul

set "cleanup_count=0"
if exist "test\CIMSpy\release-desktop\boost_python313-vc142-mt-x64-1_87.dll" (
    del test\CIMSpy\release-desktop\boost_python313-vc142-mt-x64-1_87.dll >nul 2>&1
    set /a cleanup_count+=1
)
if exist "test\CIMSpy\debug-server\boost_python313-vc142-mt-x64-1_87.dll" (
    del test\CIMSpy\debug-server\boost_python313-vc142-mt-x64-1_87.dll >nul 2>&1
    set /a cleanup_count+=1
)
if exist "test\CIMSpy\release-desktop\python313.dll" (
    del test\CIMSpy\release-desktop\python313.dll >nul 2>&1
    set /a cleanup_count+=1
)
if exist "test\CIMSpy\debug-server\python313.dll" (
    del test\CIMSpy\debug-server\python313.dll >nul 2>&1
    set /a cleanup_count+=1
)
echo Cleaned up !cleanup_count! old Python library files

echo.
echo [2/3] Copying libraries to test...
if exist "3rd-party\lib\c++" (
    xcopy 3rd-party\lib\c++ test\CIMSpy\release-desktop /s /e /i /y >nul 2>&1
    if !errorlevel! equ 0 (
        set "release_status=OK"
    ) else (
        set "release_status=FAILED"
    )
    xcopy 3rd-party\lib\c++ test\CIMSpy\debug-server /s /e /i /y >nul 2>&1
    if !errorlevel! equ 0 (
        set "debug_status=OK"
    ) else (
        set "debug_status=FAILED"
    )
    echo Libraries copied to release-desktop: !release_status!
    echo Libraries copied to debug-server: !debug_status!
    if "!release_status!"=="FAILED" (
        echo ERROR: Failed to copy libraries to release-desktop
        echo   Source: 3rd-party\lib\c++
        echo   Target: test\CIMSpy\release-desktop
    )
    if "!debug_status!"=="FAILED" (
        echo ERROR: Failed to copy libraries to debug-server
        echo   Source: 3rd-party\lib\c++
        echo   Target: test\CIMSpy\debug-server
    )
) else (
    echo ERROR: Source library directory not found
    echo   Missing: 3rd-party\lib\c++
    echo   Check if 3rd-party directory structure is correct
)



echo [3/3] Patching test directories...

set "success_count=0"
set "failed_count=0"

call :copy_with_check "3rd-party\test-patch\TestModels" "test\TestModels" "TestModels"
call :copy_with_check "3rd-party\test-patch\TestCases" "test\TestCases" "TestCases"
call :copy_with_check "3rd-party\test-patch\CIMSpy\powerflow" "test\CIMSpy\powerflow" "CIMSpy powerflow"
call :copy_with_check "3rd-party\test-patch\CIMSpy\ModelDepositories" "test\CIMSpy\ModelDepositories" "CIMSpy ModelDepositories"
call :copy_with_check "3rd-party\test-patch\CIMSpy\export" "test\CIMSpy\export" "CIMSpy export"
call :copy_with_check "3rd-party\test-patch\CIMSpy\log" "test\CIMSpy\log" "CIMSpy log"
call :copy_with_check "3rd-party\test-patch\CIMSpy\temp" "test\CIMSpy\temp" "CIMSpy temp"
call :copy_with_check "3rd-party\test-patch\CIMSpy\data" "test\CIMSpy\data" "CIMSpy data"
call :copy_with_check "3rd-party\test-patch\CIMExporter\csv" "test\CIMExporter\csv" "CIMExporter csv"
call :copy_with_check "3rd-party\test-patch\CIMExporter\log" "test\CIMExporter\log" "CIMExporter log"
call :copy_with_check "3rd-party\test-patch\CIMExporter\mrid" "test\CIMExporter\mrid" "CIMExporter mrid"
call :copy_with_check "3rd-party\test-patch\CIMExporter\cimxml" "test\CIMExporter\cimxml" "CIMExporter cimxml"

echo.
echo Test patches applied: !success_count! successful, !failed_count! failed
echo.
echo ========================================
echo PATCH INSTALLATION COMPLETED
echo ========================================
goto :end

:copy_with_check
set "source=%~1"
set "dest=%~2"
set "name=%~3"

if exist "%source%" (
    xcopy "%source%" "%dest%" /s /e /i /y >nul 2>&1
    if !errorlevel! equ 0 (
        echo %name%: OK
        set /a success_count+=1
    ) else (
        echo ERROR: %name% copy failed
        echo   Source: %source%
        echo   Target: %dest%
        set /a failed_count+=1
    )
) else (
    echo ERROR: %name% source not found
    echo   Missing: %source%
    set /a failed_count+=1
)
goto :eof

:end


