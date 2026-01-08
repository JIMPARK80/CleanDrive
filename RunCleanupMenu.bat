@echo off
echo ==============================
echo   C: Drive Cleanup Menu
echo ==============================
echo 1. Basic cleanup
echo 2. Deep cleanup
echo 3. Deep + Disable Hibernate
echo 4. Deep + Disable Hibernate + Trim Pagefile
echo.
set /p choice=Select option (1-4): 

if "%choice%"=="1" (
  powershell -ExecutionPolicy Bypass -File "%~dp0CDrive_Cleanup.ps1"
) else if "%choice%"=="2" (
  powershell -ExecutionPolicy Bypass -File "%~dp0CDrive_Cleanup.ps1" -Deep
) else if "%choice%"=="3" (
  powershell -ExecutionPolicy Bypass -File "%~dp0CDrive_Cleanup.ps1" -Deep -DisableHibernate
) else if "%choice%"=="4" (
  powershell -ExecutionPolicy Bypass -File "%~dp0CDrive_Cleanup.ps1" -Deep -DisableHibernate -TrimPageFile
) else (
  echo Invalid choice.
)

echo.
pause

