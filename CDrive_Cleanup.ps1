<# 
CDrive_Cleanup.ps1
Safe, automated cleanup for C: drive on Windows.
- Empties Recycle Bin, temp folders, Windows Update cache
- Runs DISM component cleanup
- Optionally disables hibernation and trims pagefile size
Run as Administrator. A log is saved to your Desktop.
#>

param(
    [switch]$Deep,                 # Adds AppData cache purge and SoftwareDistribution reset
    [switch]$DisableHibernate,     # powercfg -h off (removes hiberfil.sys)
    [switch]$TrimPageFile,         # sets pagefile to 1–4 GB (requires reboot to fully apply)
    [switch]$DeleteRestorePoints   # deletes ALL restore points (DANGEROUS)
)

function Require-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($MyInvocation.UnboundArguments)" -Verb RunAs
        exit
    }
}

Require-Admin

$desktop = [Environment]::GetFolderPath('Desktop')
$log = Join-Path $desktop ("CDrive_Cleanup_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".log")
Start-Transcript -Path $log -Force | Out-Null

function Get-FreeGB {
    $drive = Get-PSDrive -Name C
    [math]::Round($drive.Free/1GB,2)
}

$before = Get-FreeGB
Write-Host "Free space before: $before GB" -ForegroundColor Cyan

# 1) Empty Recycle Bin
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Recycle Bin cleared." -ForegroundColor Green
} catch { Write-Warning "Recycle Bin: $_" }

# 2) Temp folders
$paths = @(
    $env:TEMP,
    "$env:SystemRoot\Temp",
    "$env:SystemRoot\SoftwareDistribution\Download"
)

if ($Deep) {
    # Add more caches when Deep is enabled
    $users = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @('All Users','Default','Default User','Public') }
    foreach ($u in $users) {
        $paths += @(
            Join-Path $u.FullName "AppData\Local\Temp",
            Join-Path $u.FullName "AppData\Local\Packages",
            Join-Path $u.FullName "AppData\Local\CrashDumps"
        )
    }
}

foreach ($p in $paths) {
    if (Test-Path $p) {
        try {
            Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "[OK] Cleared: $p" -ForegroundColor Green
        } catch { Write-Warning "Failed to clear $p : $_" }
    }
}

# 3) Stop Update services and reset Download cache (safe)
try {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service bits -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    if (Test-Path "$env:SystemRoot\SoftwareDistribution\Download") {
        Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "[OK] Windows Update Download cache cleared." -ForegroundColor Green
    }
} catch { Write-Warning "Update cache reset: $_" } finally {
    Start-Service bits -ErrorAction SilentlyContinue | Out-Null
    Start-Service wuauserv -ErrorAction SilentlyContinue | Out-Null
}

# 4) Delivery Optimization files (safe to delete)
$doPath = "$env:ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"
if (Test-Path $doPath) {
    try {
        Get-ChildItem $doPath -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "[OK] Delivery Optimization cache cleared." -ForegroundColor Green
    } catch { Write-Warning "Delivery Optimization: $_" }
}

# 5) DISM component cleanup (can take time)
try {
    Write-Host "Running DISM component cleanup..." -ForegroundColor Yellow
    Start-Process -FilePath "dism.exe" -ArgumentList "/Online","/Cleanup-Image","/StartComponentCleanup","/ResetBase" -Wait -NoNewWindow
    Write-Host "[OK] DISM cleanup completed." -ForegroundColor Green
} catch { Write-Warning "DISM: $_" }

# 6) Optional: disable hibernation
if ($DisableHibernate) {
    try {
        powercfg -h off | Out-Null
        Write-Host "[OK] Hibernation disabled (hiberfil.sys removed)." -ForegroundColor Green
    } catch { Write-Warning "Hibernate: $_" }
}

# 7) Optional: trim pagefile to 1–4 GB (reboot may be required)
if ($TrimPageFile) {
    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $regPath -Name "PagingFiles" -Value "C:\pagefile.sys 1024 4096"
        Write-Host "[OK] Pagefile size set to 1–4 GB (reboot to apply)." -ForegroundColor Green
    } catch { Write-Warning "Pagefile: $_" }
}

# 8) Optional: delete ALL restore points (dangerous)
if ($DeleteRestorePoints) {
    try {
        vssadmin delete shadows /for=c: /all /quiet
        Write-Host "[OK] All restore points deleted." -ForegroundColor Green
    } catch { Write-Warning "Restore points: $_" }
}

$after = Get-FreeGB
$freed = [math]::Round(($after - $before),2)
Write-Host "Free space after: $after GB (Freed: $freed GB)" -ForegroundColor Cyan

Stop-Transcript | Out-Null
Write-Host "Log saved to: $log" -ForegroundColor Magenta
