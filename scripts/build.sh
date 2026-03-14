#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

IMAGE_NAME="manjaro-wsl"
CONTAINER_NAME="manjaro-wsl-export-temp"
OUTPUT_DIR="output"

echo -e "\e[36m[INFO] Starting build...\e[0m"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "\e[36m[INFO] Building Docker image...\e[0m"
docker build -t "$IMAGE_NAME" -f docker/Dockerfile .

echo -e "\e[36m[INFO] Creating container for export...\e[0m"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" > /dev/null

echo -e "\e[36m[INFO] Exporting RootFS...\e[0m"
docker export "$CONTAINER_NAME" | gzip > "$OUTPUT_DIR/rootfs.tar.gz"
docker rm -f "$CONTAINER_NAME" > /dev/null

echo -e "\e[36m[INFO] Verifying wsl.conf in rootfs...\e[0m"
if ! tar -xOf "$OUTPUT_DIR/rootfs.tar.gz" etc/wsl.conf 2>/dev/null | grep -q .; then
    echo -e "\e[31m[ERROR] etc/wsl.conf is missing or empty in the exported rootfs.\e[0m"
    exit 1
fi

echo -e "\e[32m------------------------------------------------\e[0m"
echo -e "\e[32mSUCCESS! Build finished.\e[0m"
echo -e "Files generated at: ./$OUTPUT_DIR"
echo -e "\e[32m------------------------------------------------\e[0m"
