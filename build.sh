#!/bin/bash
set -e

IMAGE_NAME="manjaro-wsl-clean"
CONTAINER_NAME="manjaro-wsl-export-temp"
OUTPUT_DIR="output"
ICONS_ZIP_URL="https://github.com/yuk7/wsldl/releases/latest/download/icons.zip"

echo -e "\e[36m[INFO] Iniciando build v3.0 (Smart - No Wine)...\e[0m"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "\e[36m[INFO] Buildando imagem Docker...\e[0m"
docker build -t "$IMAGE_NAME" .

echo -e "\e[36m[INFO] Criando container para exportação...\e[0m"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" > /dev/null

echo -e "\e[36m[INFO] Exportando RootFS...\e[0m"
docker export "$CONTAINER_NAME" | gzip > "$OUTPUT_DIR/rootfs.tar.gz"

echo -e "\e[36m[INFO] Baixando Launcher Manjaro oficial (pré-iconizado)...\e[0m"
curl -L -o "$OUTPUT_DIR/icons.zip" "$ICONS_ZIP_URL"

echo -e "\e[36m[INFO] Extraindo Manjaro.exe...\e[0m"
unzip -q -j "$OUTPUT_DIR/icons.zip" "Manjaro.exe" -d "$OUTPUT_DIR"

rm "$OUTPUT_DIR/icons.zip"
docker rm -f "$CONTAINER_NAME" > /dev/null

echo -e "\e[32m------------------------------------------------\e[0m"
echo -e "\e[32mSUCESSO! Build finalizado.\e[0m"
echo -e "Arquivos gerados em: ./$OUTPUT_DIR"
echo -e "\e[32m------------------------------------------------\e[0m"