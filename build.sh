#!/bin/bash
set -e

IMAGE_NAME="manjaro-wsl"
CONTAINER_NAME="manjaro-wsl-export-temp"
OUTPUT_DIR="output"
ICONS_ZIP_URL="https://github.com/yuk7/wsldl/releases/latest/download/icons.zip"

echo -e "\e[36m[INFO] Starting build...\e[0m"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "\e[36m[INFO] Building Docker image...\e[0m"
docker build -t "$IMAGE_NAME" .

echo -e "\e[36m[INFO] Creating container for export...\e[0m"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" > /dev/null

echo -e "\e[36m[INFO] Exporting RootFS...\e[0m"
docker export "$CONTAINER_NAME" | gzip > "$OUTPUT_DIR/rootfs.tar.gz"

echo -e "\e[36m[INFO] Downloading official wsldl Manjaro Launcher...\e[0m"
curl -L -o "$OUTPUT_DIR/icons.zip" "$ICONS_ZIP_URL"

echo -e "\e[36m[INFO] Extracting Manjaro.exe...\e[0m"
unzip -q -j "$OUTPUT_DIR/icons.zip" "Manjaro.exe" -d "$OUTPUT_DIR"

rm "$OUTPUT_DIR/icons.zip"
docker rm -f "$CONTAINER_NAME" > /dev/null

echo -e "\e[32m------------------------------------------------\e[0m"
echo -e "\e[32mSUCCESS! Build finished.\e[0m"
echo -e "Files generated at: ./$OUTPUT_DIR"
echo -e "\e[32m------------------------------------------------\e[0m"