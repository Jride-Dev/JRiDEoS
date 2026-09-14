#!/bin/bash
# JRiDEoS Studio builder — run INSIDE studio/ dir on Debian (Codespace/CI)
# Usage: ./build.sh
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

echo "[*] Configuring (studio)..."
sh auto/config

echo "[*] Building Studio ISO (15-30 min, KDE is big)..."
set -o pipefail
lb build 2>&1 | tee build.log

echo ""
echo "[OK] Done:"
ls -lh *.iso
echo ""
echo "NOTE: Studio ISO is ~3GB (Plasma + Wine + Ardour/OBS)."
echo "GitHub Releases cap files at 2GB — if the ISO exceeds that,"
echo "ship via Actions artifact (gh run download) instead of a release asset."
echo ""
echo "Test:"
echo "  qemu-system-x86_64 -enable-kvm -m 6G -vga virtio -cdrom jrideos-studio-2.0-amd64.hybrid.iso -boot d"
