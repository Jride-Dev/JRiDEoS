#!/bin/bash
# JRiDEoS builder — run inside Codespace / Debian trixie
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

echo "[*] Configuring..."
sh auto/config

echo "[*] Building ISO (this takes 10-25 min)..."
lb build 2>&1 | tee build.log

echo ""
echo "[OK] Done:"
ls -lh *.iso *.hybrid.iso 2>/dev/null || ls -lh *.iso
echo ""
echo "Test in QEMU:"
echo "  qemu-system-x86_64 -enable-kvm -m 4G -vga virtio -cdrom jrideos-tgl-1.0-amd64.hybrid.iso -boot d"
echo "Flash to USB:"
echo "  sudo dd if=jrideos-tgl-1.0-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress oflag=sync"
