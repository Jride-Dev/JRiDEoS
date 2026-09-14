#!/bin/bash
# JRiDEoS Studio-UI builder — run INSIDE studio-ui/ dir on Debian (Codespace/CI)
# Usage: ./build.sh
# Pins (verified upstream tags, override as env):
#   YABRIDGE_VER=5.1.1 GE_PROTON_VER=GE-Proton11-6 ./build.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Re-running with sudo..."
  exec sudo bash "$0" "$@"
fi

echo "[*] Installing live-build deps..."
apt-get update
apt-get install -y --no-install-recommends \
  live-build debootstrap cdebootstrap \
  squashfs-tools xorriso isolinux syslinux-efi \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools arch-test

echo "[*] Cleaning previous build..."
lb clean --purge || true

echo "[*] Configuring (studio-ui)..."
sh auto/config

echo "[*] Building Studio-UI ISO (20-40 min: Plasma + Wine-Staging + GE-Proton)..."
set -o pipefail
lb build 2>&1 | tee build.log

echo ""
echo "[OK] Done:"
ls -lh *.iso
echo ""
echo "NOTE: Studio-UI ISO is ~3.5GB (Plasma + Wine-Staging + GE-Proton + DAWs)."
echo "GitHub Releases cap files at 2GB — ship via Actions artifact"
echo "(gh run download --name jrideos-studio-ui-iso) if the release step fails."
