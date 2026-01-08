@echo off
echo Moving project to D:\1.DevProjects\Tools\CleanDrive...
mkdir "D:\1.DevProjects\Tools" 2>nul
move "C:\Users\JINSUNG_SUPER SONIC\Downloads\CleanDrive" "D:\1.DevProjects\Tools\CleanDrive"
if %ERRORLEVEL% EQU 0 (
    echo Move successful!
) else (
    echo Move failed.
)
pause
