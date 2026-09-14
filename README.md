# JRiDEoS

Lightweight, bloat-free Debian-based live OS for the **Gateway GWTN141-10**
(i5-1135G7 Tiger Lake + Iris Xe, 16GB RAM, 512GB NVMe).

- Base: Debian 13 `trixie` + live-build, kernel 6.12 LTS
- Desktop: XFCE minimal + LightDM (snappy, ~550MB idle)
- Graphics: Mesa Iris + `intel-media-driver` (iHD) VA-API
- Audio: SOF Tiger Lake + PipeWire
- Net: `iwlwifi` (Intel AC9461/AX201) + Realtek fallback, BT 5.0 on-demand
- Security: AppArmor enforce, UFW deny-inbound, DNS-over-TLS (Quad9/Cloudflare), Firefox-ESR locked-down + uBlock, unattended security updates

> Fingerprint reader (Goodix) has no Linux driver — blacklisted by design.

## Build in your Codespace

This repo is pre-wired for GitHub Codespaces / github.dev:

1. Open the Codespace: https://humble-space-carnival-65w95grgpjqh47v.github.dev/ (or your Codespace)
2. The `.devcontainer` auto-installs `live-build` deps.
3. Run:

```bash
chmod +x build.sh auto/config
./build.sh
```

Output: `jrideos-tgl-1.0-amd64.hybrid.iso`

Or push to `main` — `.github/workflows/build-iso.yml` builds the ISO in CI and uploads it as an artifact.

## JRiDEoS Studio 2.0 (DAW + gaming spin)

Second profile in `studio/`: PREEMPT_RT kernel, KDE Plasma Wayland, PipeWire-JACK,
Mesa ANV, Steam/Proton/Wine, Ardour/Audacity/OBS. See `studio/README.md`.

```bash
./build-studio.sh
```

Tag `studio-v*` builds + attaches the Studio ISO to a GitHub release.

## JRiDEoS Studio-UI (VST-heavy DAW + gaming spin)

Third profile in `studio-ui/`, tagged `studio-ui-v*`: everything in Studio,
plus **native** Wine-Staging (WineHQ), Yabridge + `yabridge-sync-all` auto-sync,
GE-Proton template, UFW/firewall + RT configs. See `studio-ui/README.md`.

```bash
./build-studio-ui.sh
```

> Studio-UI ISO is ~3.5GB — over GitHub's 2GB release-asset cap, so ship it
> via the Actions artifact (`jrideos-studio-ui-iso`), not the release.

## Test

```bash
qemu-system-x86_64 -enable-kvm -m 4G -vga virtio -cdrom jrideos-tgl-1.0-amd64.hybrid.iso -boot d
sudo dd if=jrideos-tgl-1.0-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Verify on hardware (GWTN141-10)

```bash
vainfo | grep -i iHD
intel_gpu_top
dmesg | grep -E "i915|GuC|HuC|DMC|SOF|iwlwifi"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver  # intel_pstate
ss -tulpn  # should show no LAN listeners
aa-status
ufw status verbose
resolvectl status | grep -i "DNSOverTLS\|DNSSEC"
```

## Layout

```text
auto/config                              live-build config (trixie, UEFI+Secure Boot)
config/package-lists/jride.list.chroot   minimal package set
config/hooks/live/0100-tgl-firmware.*    thermald, NM, apparmor, bloat removal
config/hooks/live/0101-security.*        UFW, unattended-upgrades, fail2ban
config/includes.chroot/etc/...           i915 opts, sysctl, DoH, sleep, Firefox policies, LightDM
build.sh                                 one-shot builder
.devcontainer/                           Codespace with live-build preinstalled
.github/workflows/build-iso.yml          CI ISO build
```
