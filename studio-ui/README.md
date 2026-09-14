# JRiDEoS Studio-UI — VST-heavy DAW + gaming spin for Gateway GWTN141-10

Debian 13 `trixie` live ISO, tagged `studio-ui-v*`: PREEMPT_RT kernel, KDE
Plasma Wayland, **native Wine-Staging (WineHQ) + Yabridge 5.1.1 + GE-Proton**
baked in, PipeWire-JACK, Ardour/Audacity/OBS native.

## Base rationale

Same `live-build` framework as v1/Studio: signed RT kernel (Secure Boot OK),
`non-free-firmware` for Tiger Lake, one repo + one CI pattern. Archiso would
give newer Plasma/Wine by weeks but rolling kernels break SOF + `snd-usb-audio`
quirks mid-tour; Ubuntu Studio drags in Snaps. Trixie + WineHQ + pinned
upstreams is the stable middle.

## What's native in-image (no post-install needed for VSTs)

- `winehq-staging` from WineHQ `trixie` repo (hook `0210`, fails loudly if WineHQ is down)
- `:i386` Mesa ANV + Vulkan multilib for Proton and plugin GUIs
- Yabridge 5.1.1 system-wide (`/usr/share/yabridge`, `yabridgectl` on PATH)
- GE-Proton template at `/opt/Proton-GE` (per-user Steam link via firstboot)
- RT: `threadirqs preempt=full`, rtirq (`snd_usb_audio` first), `@audio` rtprio 95
- UFW deny-in/allow-out enabled, AppArmor enforced, unattended security updates

## VST workflow: install, path, sync

1. First boot: `sudo jride-studio-ui-firstboot`, log out/in.
2. Install your Windows plugins into the default prefix with Wine-Staging
   (`wine installer.exe`), or set `WINEPREFIXES=/data/vst-prefix:...`.
3. Sync (auto-runs at every KDE login too):
   ```bash
   yabridge-sync-all              # scan ~/.wine + $WINEPREFIXES, add + sync
   yabridge-sync-all --prefix ~/Games/omnisphere-pfx
   ```
   Scanned per prefix: `VSTPlugins`, `Steinberg/VstPlugins`, `Common Files/VST2`,
   `Common Files/VST3`, `VST3`, `Common Files/CLAP`, `CLAP`.
4. REAPER/Ardour: rescan — bridged plugins appear as `yabridge: Name`.
   Per-plugin quirks: drop a `yabridge.toml` next to the `.dll`/`.vst3`.
5. Keep current: `install-proton-ge latest`, re-run `yabridge-sync-all`.

Key env vars: `WINEPREFIXES` (extra prefixes), `YABRIDGE_BIN`,
`YABRIDGE_VER` / `GE_PROTON_VER` (build-time pins).

## Gaming

Steam > game Properties > Compatibility > GE-Proton. Recommended launch options
on Iris Xe: `gamemoderun mangohud %command%`. MangoHud toggles with
`Shift_R+F12`. Fractional scaling: System Settings > Display > 125%/150%.

## Build

```bash
./build-studio-ui.sh
# pins: YABRIDGE_VER=5.1.1 GE_PROTON_VER=GE-Proton11-6 ./build-studio-ui.sh
```

Output: `studio-ui/jrideos-studio-ui-1.0-amd64.hybrid.iso` (~3.5GB).
CI: pushes touching `studio-ui/**` build artifact `jrideos-studio-ui-iso`;
tag `studio-ui-v*` also attaches to the release — **but GitHub caps release
files at 2GB, so expect the release step to fail and use
`gh run download --name jrideos-studio-ui-iso` instead.**

## Verify

```bash
cat /sys/kernel/realtime   # 1
ulimit -r                  # 95 (after firstboot + relogin)
wine --version             # staging
yabridgectl --version      # 5.1.1
ls /opt/Proton-GE/compatibilitytool.vdf
pw-top
ufw status verbose; aa-status
```
