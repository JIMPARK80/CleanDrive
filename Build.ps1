# Build script for CDriveCleaner
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "  Building CDriveCleaner" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Check if dotnet is installed
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: .NET SDK is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install .NET 6.0 SDK or later from https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Building release version..." -ForegroundColor Green
dotnet publish CDriveCleaner.csproj -c Release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==============================" -ForegroundColor Green
    Write-Host "  Build Successful!" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output location: bin\Release\net6.0-windows\win-x64\publish\" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Copy CDriveCleaner.exe and CDrive_Cleanup.ps1 to the same folder" -ForegroundColor Cyan
    Write-Host "to distribute to other users." -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host ""
}

Read-Host "Press Enter to exit"

