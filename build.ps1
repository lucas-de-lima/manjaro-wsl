$ErrorActionPreference = "Stop"

# Configuration
$ImageName = "manjaro-wsl-clean"
$ContainerName = "manjaro-wsl-export-temp"
${OutputDir} = "output"
$WsldlUrl = "https://github.com/yuk7/wsldl/releases/latest/download/wsldl.exe"
$IconUrl = "https://github.com/yuk7/wsldl/raw/main/res/Manjaro/icon.ico"
$RceditUrl = "https://github.com/electron/rcedit/releases/latest/download/rcedit-x64.exe"

Write-Host "[INFO] Starting build process v2.1 (Clean)..." -ForegroundColor Cyan

# 1. Cleanup
if (Test-Path ${OutputDir}) {
    Remove-Item -Path ${OutputDir} -Recurse -Force
}
New-Item -ItemType Directory -Force -Path ${OutputDir} | Out-Null

# 2. Docker Build
Write-Host "[INFO] Building Docker image (Clean)..." -ForegroundColor Cyan
docker build -t $ImageName .
if ($LASTEXITCODE -ne 0) { throw "Docker build failed" }

# 3. Temporary Container
Write-Host "[INFO] Creating temporary container..." -ForegroundColor Cyan
if (docker ps -a -q -f name=$ContainerName) { docker rm -f $ContainerName | Out-Null }
docker create --name $ContainerName $ImageName | Out-Null

# 4. Export
Write-Host "[INFO] Exporting RootFS..." -ForegroundColor Cyan
cmd /c "docker export $ContainerName > ${OutputDir}\rootfs.tar.gz"

# 5. Downloading artifacts
Write-Host "[INFO] Downloading launcher + icon..." -ForegroundColor Cyan

# wsldl launcher
curl.exe -L -o "${OutputDir}\Manjaro.exe" $WsldlUrl

# official wsldl icon
curl.exe -L -o "${OutputDir}\icon.ico" $IconUrl

# rcedit to embed the icon
Write-Host "[INFO] Downloading rcedit..." -ForegroundColor Cyan
curl.exe -L -o "${OutputDir}\rcedit.exe" $RceditUrl

# 6. Applying icon to the executable
Write-Host "[INFO] Applying icon to launcher..." -ForegroundColor Cyan
& "${OutputDir}\rcedit.exe" "${OutputDir}\Manjaro.exe" --set-icon "${OutputDir}\icon.ico"

# 7. Cleanup
docker rm -f $ContainerName | Out-Null
Remove-Item "${OutputDir}\rcedit.exe"

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "SUCCESS! Build finished." -ForegroundColor Green
Write-Host "RootFS + Launcher with icon ready at: .\${OutputDir}"
Write-Host "------------------------------------------------"