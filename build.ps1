# Abort on critical command errors, but handle cleanup intelligently
$ErrorActionPreference = "Stop"

# Configuration
$ImageName = "manjaro-wsl-final"
$ContainerName = "manjaro-wsl-export-temp"
$OutputDir = "output"
$WsldlUrl = "https://github.com/yuk7/wsldl/releases/latest/download/wsldl.exe"

Write-Host "[INFO] Starting build process..." -ForegroundColor Cyan

# 1. Cleanup and Directory Preparation
if (Test-Path $OutputDir) {
    Write-Host "[INFO] Cleaning old output directory..." -ForegroundColor Yellow
    Remove-Item -Path $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# 2. Docker Image Build
Write-Host "[INFO] Building Docker image..." -ForegroundColor Cyan
try {
    # Build can be cached, it's fast
    docker build -t $ImageName .
    if ($LASTEXITCODE -ne 0) { throw "Docker build failed" }
}
catch {
    Write-Host "[ERROR] Docker image build failed." -ForegroundColor Red
    exit 1
}

# 3. Container Creation (With intelligent cleanup beforehand)
Write-Host "[INFO] Creating temporary container..." -ForegroundColor Cyan

# Check if it exists before trying to kill it, so PowerShell doesn't complain
if (docker ps -a -q -f name=$ContainerName) {
    Write-Host "       Removing residual container..." -ForegroundColor Gray
    docker rm -f $ContainerName | Out-Null
}

# Create new one
docker create --name $ContainerName $ImageName | Out-Null

# Verify it was actually created
if (-not (docker ps -a -q -f name=$ContainerName)) {
    Write-Host "[ERROR] The container was not created." -ForegroundColor Red
    exit 1
}

# 4. RootFS Export ("Raw" version - More compatible)
Write-Host "[INFO] Exporting rootfs (without compression to avoid WinAPI errors)..." -ForegroundColor Cyan

try {
    # Export directly as .tar.gz (but the content is pure tar). 
    # wsldl accepts pure tar even with .gz extension, and this avoids error 0x80040326
    cmd /c "docker export $ContainerName > $OutputDir\rootfs.tar.gz"
}
catch {
    Write-Host "[ERROR] Export failed." -ForegroundColor Red
    exit 1
}

# 5. Downloading the Launcher
Write-Host "[INFO] Downloading wsldl launcher..." -ForegroundColor Cyan
try {
    curl.exe -L -o "$OutputDir\Manjaro.exe" $WsldlUrl
}
catch {
    Write-Host "[ERROR] Failed to download wsldl." -ForegroundColor Red
    exit 1
}

# 6. Final Cleanup (Intelligent)
Write-Host "[INFO] Cleaning up container..." -ForegroundColor Yellow
if (docker ps -a -q -f name=$ContainerName) {
    docker rm -f $ContainerName | Out-Null
}

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "SUCCESS! Build completed." -ForegroundColor Green
Write-Host "Files generated in: .\$OutputDir"
Write-Host "------------------------------------------------"