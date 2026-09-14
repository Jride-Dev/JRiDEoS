# JRiDEoS Studio 2.0 — DAW + gaming spin for Gateway GWTN141-10

High-performance, bloat-free Debian 13 `trixie` live ISO: PREEMPT_RT kernel,
KDE Plasma Wayland, PipeWire-JACK, Mesa ANV Vulkan, Steam/Proton/Wine,
Ardour/Audacity/OBS native.

## What's inside

- **Kernel:** `linux-image-rt-amd64` 6.12-RT (signed, Secure Boot OK)
  + `threadirqs preempt=full` live + installed, `rtirq-init` prioritizes
  `snd_usb_audio > SOF/HDA > i915/xhci/nvme`, `@audio` rtprio 95 / memlock unlimited
- **Desktop:** KDE Plasma Wayland + SDDM, 125%/150% fractional scaling for 14.1" FHD
- **Graphics:** Mesa ANV + `intel-media-va-driver` (iHD), MangoHud, GameMode, Gamescope
- **Audio:** PipeWire + `pipewire-jack/alsa/pulse`, `qpwgraph`, HDA power-save OFF (no xrun clicks)
- **Creation:** Ardour, Audacity, OBS, CALF/LSP/x42 plugins native;
  REAPER / wine-staging / yabridge via `/usr/local/bin/install-*` scripts
- **Gaming 32-bit:** `:i386` ANV + Vulkan in-image; Steam bootstraps the rest

> Goodix fingerprint reader blacklisted (no Linux driver, reduces USB jitter).
> `mitigations=off` is deliberately NOT set — keep default mitigations; add it
> yourself in GRUB if you want the last 5% gaming FPS.

## Build

```bash
./build-studio.sh
# or: cd studio && ./build.sh
```

Output: `studio/jrideos-studio-2.0-amd64.hybrid.iso` (~3GB).

CI: push touching `studio/**` builds artifact `jrideos-studio-iso`;
tag `studio-v*` additionally attaches it to the GitHub release.
**Heads-up:** GitHub release assets cap at 2GB/file — if the Plasma ISO
exceeds that, the release step fails; the Actions artifact still works
(`gh run download --name jrideos-studio-iso`).

## First boot (live or installed)

```bash
sudo jride-studio-firstboot   # audio/video groups, RT check; then log out/in
cat /sys/kernel/realtime      # 1
ulimit -r                     # 95
rtirq status
pw-top                        # DSP load
pw-jack ardour8
vulkaninfo --summary | grep -i "ANV.*Intel"
mangohud glxgears
```

Windows plugins: `sudo install-wine-staging`, then `install-yabridge`,
then `sudo install-reaper 7.25`.
