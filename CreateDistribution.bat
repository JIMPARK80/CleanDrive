@echo off
echo ==============================
echo   Creating Distribution Package
echo ==============================
echo.

REM Build the application first
call Build.bat
if %ERRORLEVEL% NEQ 0 (
    echo Build failed, cannot create distribution package.
    pause
    exit /b 1
)

echo.
echo Creating distribution folder...
set DIST_DIR=CDriveCleaner_Distribution
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

echo Copying files...
copy "bin\Release\net6.0-windows\win-x64\publish\CDriveCleaner.exe" "%DIST_DIR%\"
copy "CDrive_Cleanup.ps1" "%DIST_DIR%\"
copy "README.md" "%DIST_DIR%\"

echo.
echo ==============================
echo   Distribution Package Created!
echo ==============================
echo.
echo Location: %DIST_DIR%\
echo.
echo This folder contains everything needed to distribute:
echo   - CDriveCleaner.exe (standalone, no .NET installation needed)
echo   - CDrive_Cleanup.ps1 (PowerShell script)
echo   - README.md (instructions)
echo.
echo You can zip this folder and share it with others.
echo.
pause

