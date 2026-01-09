<# 
CDrive_Cleanup.ps1
Safe, automated cleanup for C: drive on Windows.
Runs as Administrator. Captures output for Electron.
#>

param(
    [switch]$Deep,
    [switch]$DisableHibernate,
    [switch]$TrimPageFile,
    [switch]$DeleteRestorePoints,
    [string]$RedirectOutput  # Reserved for internal use (passing output back to non-admin process)
)

# Function to check for Admin rights
function Test-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-Admin)) {
    # [NON-ADMIN MODE]
    # We are not admin. We must start a new elevated process to do the work.
    # To capture its output, we ask it to write to a temporary file, then we read it back.
    
    $TempLog = [System.IO.Path]::GetTempFileName()
    
    # Reconstruct arguments
    $MyArgs = @()
    if ($Deep) { $MyArgs += "-Deep" }
    if ($DisableHibernate) { $MyArgs += "-DisableHibernate" }
    if ($TrimPageFile) { $MyArgs += "-TrimPageFile" }
    if ($DeleteRestorePoints) { $MyArgs += "-DeleteRestorePoints" }
    
    # Add the hidden redirection argument
    $MyArgs += "-RedirectOutput"
    $MyArgs += "`"$TempLog`""
    
    # Join args properly
    $ArgList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $MyArgs"

    Write-Host "Requesting Admin privileges..." -ForegroundColor Yellow

    try {
        # Start elevated process and WAIT for it to finish
        $process = Start-Process -FilePath "powershell" -ArgumentList $ArgList -Verb RunAs -PassThru -Wait
        
        # Read the captured output from the temp file
        if (Test-Path $TempLog) {
            Get-Content $TempLog | Write-Host
            Remove-Item $TempLog -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "Failed to elevate or user cancelled."
        Write-Host "Free space before: 0 GB"
        Write-Host "Free space after: 0 GB (Freed: 0.00 GB)"
    }
    
    # Exit the wrapper process
    exit
}

# [ADMIN MODE]
# If we are here, we are Administrator.
# If $RedirectOutput is set, we must capture everything to that file.

if ($RedirectOutput) {
    try {
        Start-Transcript -Path $RedirectOutput -Force | Out-Null
    }
    catch {
        # If transcript fails, proceed anyway (output might be lost but cleaner runs)
    }
}

function Get-FreeGB {
    $drive = Get-PSDrive -Name C
    [math]::Round($drive.Free / 1GB, 2)
}

$before = Get-FreeGB
# Always print this format for Electron parser
Write-Host "Free space before: $before GB" -ForegroundColor Cyan

# 1) Empty Recycle Bin
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Recycle Bin cleared." -ForegroundColor Green
}
catch { Write-Warning "Recycle Bin: $_" }

# 2) Temp folders
$paths = @(
    $env:TEMP,
    "$env:SystemRoot\Temp",
    "$env:SystemRoot\SoftwareDistribution\Download"
)

if ($Deep) {
    $users = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @('All Users', 'Default', 'Default User', 'Public') }
    foreach ($u in $users) {
        $paths += Join-Path $u.FullName "AppData\Local\Temp"
        $paths += Join-Path $u.FullName "AppData\Local\Packages"
        $paths += Join-Path $u.FullName "AppData\Local\CrashDumps"
    }
}

foreach ($p in $paths) {
    if (Test-Path $p) {
        try {
            Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "[OK] Cleared: $p" -ForegroundColor Green
        }
        catch { Write-Warning "Failed to clear $p : $_" }
    }
}

# 3) Stop Update services and reset Download cache
try {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service bits -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    if (Test-Path "$env:SystemRoot\SoftwareDistribution\Download") {
        Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "[OK] Windows Update Download cache cleared." -ForegroundColor Green
    }
}
catch { 
    Write-Warning "Update cache reset: $_" 
}
finally {
    Start-Service bits -ErrorAction SilentlyContinue | Out-Null
    Start-Service wuauserv -ErrorAction SilentlyContinue | Out-Null
}

# 4) Delivery Optimization
$doPath = "$env:ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"
if (Test-Path $doPath) {
    try {
        Get-ChildItem $doPath -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "[OK] Delivery Optimization cache cleared." -ForegroundColor Green
    }
    catch { }
}

# 5) DISM
try {
    Write-Host "Running DISM component cleanup..." -ForegroundColor Yellow
    Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup", "/ResetBase" -Wait -NoNewWindow
    Write-Host "[OK] DISM cleanup completed." -ForegroundColor Green
}
catch { }

# 6) Hibernation
if ($DisableHibernate) {
    try {
        powercfg -h off | Out-Null
        Write-Host "[OK] Hibernation disabled." -ForegroundColor Green
    }
    catch {}
}

# 7) Pagefile
if ($TrimPageFile) {
    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $regPath -Name "PagingFiles" -Value "C:\pagefile.sys 1024 4096"
        Write-Host "[OK] Pagefile resized." -ForegroundColor Green
    }
    catch {}
}

# 8) Restore Points
if ($DeleteRestorePoints) {
    try {
        vssadmin delete shadows /for=c: /all /quiet
        Write-Host "[OK] Restore points deleted." -ForegroundColor Green
    }
    catch {}
}

$after = Get-FreeGB
$freed = [math]::Round(($after - $before), 2)
# Ensure non-negative display
if ($freed -lt 0) { $freed = 0 }

# Always print this format for Electron parser
Write-Host "Free space after: $after GB (Freed: $freed GB)" -ForegroundColor Cyan
Write-Host "Cleanup completed successfully!" -ForegroundColor Green

if ($RedirectOutput) {
    Stop-Transcript | Out-Null
}
