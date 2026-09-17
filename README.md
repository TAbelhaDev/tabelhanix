<div align="center">

# TAbelhaNix

**A NixOS flake installer for the niri + DankMaterialShell stack** — the
NixOS sibling of [TAbelhaArch](https://github.com/TAbelhaDev/tabelhaarch),
targeting the same desktop stack defined in
[TAbelhaOS](https://github.com/TAbelhaDev/tabelhaos).

**English** · [Português](README.pt-BR.md)

[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ianptkcs)

</div>

---

> **Status: in development.** Flake evaluated and modules validated. Testing with nix flake check.

## How to use

### Boot from USB (recommended)

1. Build the ISO (or download from GitHub Releases):
   ```bash
   nix build .#nixosConfigurations.tabelhanix-iso.config.system.build.isoImage
   # ISO is at ./result/iso/nixos-*.iso
   ```

2. Flash to USB (e.g. with `dd` or [Etcher](https://etcher.balena.io/)):
   ```bash
   sudo dd if=./result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress
   ```

3. Boot from USB → auto-login into niri + DankMaterialShell live session

4. Open a terminal and run:
   ```bash
   tabelhanix-install
   ```
   This clones the repo and runs the interactive installer.

### Manual installation (existing NixOS)

```bash
git clone https://github.com/TAbelhaDev/tabelhanix.git
cd tabelhanix
sudo nixos-rebuild switch --flake .#tabelhanix
```

### Available configurations

| Config | Description |
|--------|-------------|
| `tabelhanix` | Default desktop (no GPU accel) |
| `tabelhanix-nvidia` | NVIDIA + laptop + gaming + dev |
| `tabelhanix-minimal` | Bare minimum, no extra packages |
| `tabelhanix-laptop` | Laptop optimizations (TLP, Bluetooth) |
| `tabelhanix-intel` | Intel GPU + VA-API |
| `tabelhanix-amd` | AMD GPU + Vulkan |
| `tabelhanix-iso` | Bootable live USB |

## What this will be

A flake-based NixOS configuration covering the same ground TAbelhaArch's
`install/` covers for Arch, targeting:

- **niri** via [sodiboo/niri-flake](https://github.com/sodiboo/niri-flake)
- **DankMaterialShell** via its own NixOS + home-manager modules
- **NVIDIA Optimus/PRIME** via `hardware.nvidia.prime.*`, per
  [TAbelhaOS's `spec/optimus.md`](https://github.com/TAbelhaDev/tabelhaos/blob/main/spec/optimus.md)
- The package set in
  [TAbelhaOS's `manifest/packages.toml`](https://github.com/TAbelhaDev/tabelhaos/blob/main/manifest/packages.toml),
  using its `nixpkgs` column

## Available Configurations

| Configuration | Description |
|---------------|-------------|
| `tabelhanix` | Default desktop configuration |
| `tabelhanix-nvidia` | Desktop with NVIDIA GPU support |
| `tabelhanix-minimal` | Minimal configuration |
| `tabelhanix-laptop` | Laptop-specific configuration |
| `tabelhanix-intel` | Desktop with Intel GPU |
| `tabelhanix-amd` | Desktop with AMD GPU |

## Documentation

- [Usage Guide](docs/usage.md)
- [Architecture](docs/architecture.md)

TAbelhaArch and TAbelhaNix don't share install code — bash/gum and Nix modules
are different enough that forcing a shared abstraction would fight both.
They share only the target-stack definition, in TAbelhaOS.
