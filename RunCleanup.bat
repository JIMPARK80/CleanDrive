@echo off
REM Run C drive cleanup with Deep + DisableHibernate
powershell -ExecutionPolicy Bypass -File "%~dp0CDrive_Cleanup.ps1" -Deep -DisableHibernate
pause

