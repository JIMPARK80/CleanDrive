@echo off
echo ==============================
echo   Building CDriveCleaner
echo ==============================
echo.

REM Check if dotnet is installed
where dotnet >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: .NET SDK is not installed or not in PATH.
    echo Please install .NET 6.0 SDK or later from https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

echo Building release version...
dotnet publish CDriveCleaner.csproj -c Release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==============================
    echo   Build Successful!
    echo ==============================
    echo.
    echo Output location: bin\Release\net6.0-windows\win-x64\publish\
    echo.
    echo Copy CDriveCleaner.exe and CDrive_Cleanup.ps1 to the same folder
    echo to distribute to other users.
    echo.
) else (
    echo.
    echo Build failed!
    echo.
)

pause

