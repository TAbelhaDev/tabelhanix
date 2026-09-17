# TAbelhaNix Architecture

## Overview

TAbelhaNix is a NixOS flake installer for the niri + DankMaterialShell stack, mirroring what TAbelhaArch does for Arch Linux.

## Project Structure

```
tabelhanix/
├── flake.nix                    # Main flake configuration
├── modules/
│   ├── nixos.nix               # Core NixOS system configuration
│   ├── options.nix             # Custom options (tabelhanix.*)
│   ├── dms.nix                 # DankMaterialShell configuration
│   ├── nvidia.nix              # NVIDIA Optimus/PRIME configuration
│   ├── sops.nix                # Secrets management (sops-nix)
│   ├── impermanence.nix        # Root on tmpfs with persistence
│   └── hardware/
│       ├── intel.nix           # Intel GPU configuration
│       ├── amd.nix             # AMD GPU configuration
│       └── laptop.nix          # Laptop optimizations
├── home/
│   ├── default.nix             # Full Home Manager configuration
│   ├── minimal.nix             # Minimal Home Manager configuration
│   └── dotfiles.nix            # CLI tool configurations
├── scripts/
│   ├── install.sh              # Interactive installer
│   ├── hardware-detect.sh      # Hardware detection
│   ├── rollback.sh             # Generation rollback
│   └── test.sh                 # Flake testing
├── tests/
│   └── default.nix             # NixOS tests
├── secrets/
│   └── secrets.yaml.template   # Secrets template
├── docs/
│   ├── architecture.md         # This file
│   ├── usage.md                # Usage guide
│   └── troubleshooting.md      # Troubleshooting guide
└── .github/
    └── workflows/
        ├── ci.yml              # CI pipeline
        ├── format.yml          # Formatting checks
        ├── release.yml         # Release automation
        └── update.yml          # Flake input updates
```

## Design Decisions

### Flake Structure

- **nixpkgs**: Uses `nixos-unstable` for latest package availability
- **niri**: Via `sodiboo/niri-flake` for version pinned independently of nixpkgs
- **DankMaterialShell**: Via its official flake with NixOS modules
- **Home Manager**: For user-level configuration management
- **sops-nix**: For secrets management
- **impermanence**: For root on tmpfs with persistent state

### Options System

TAbelhaNix uses a custom options system (`tabelhanix.*`) for configuration:

```nix
tabelhanix = {
  gpu = "nvidia";           # none, intel, amd, nvidia
  laptop = true;            # Laptop optimizations
  gaming = true;            # Gaming packages
  dev = true;               # Development tools
  bluetooth = true;         # Bluetooth support
  vm = true;                # Virtualization
  flatpak = true;           # Flatpak support
  postgresql = false;       # PostgreSQL server
  redis = false;            # Redis server
  username = "tabelha";     # Primary user
  hostname = "tabelhanix";  # System hostname
  timezone = "America/Sao_Paulo";
  locale = "pt_BR.UTF-8";
  keyboardLayout = "us";
  keyboardVariant = null;
};
```

### Module Separation

- `nixos.nix`: Core system configuration (boot, networking, services)
- `options.nix`: Custom options definitions
- `dms.nix`: DankMaterialShell configuration
- `nvidia.nix`: NVIDIA GPU support (conditional)
- `sops.nix`: Secrets management (optional)
- `impermanence.nix`: Root on tmpfs (optional)
- `hardware/*.nix`: GPU-specific and laptop configurations

### Package Management

- System packages in `nixos.nix` (conditional via options)
- User packages in `home/default.nix`
- DMS packages managed by upstream module
- No duplication between layers

### NVIDIA Optimus/PRIME

Following `TAbelhaOS/spec/optimus.md`:
- Open-source kernel module (`hardware.nvidia.open = true`)
- Configurable PCI bus IDs
- PRIME mode selection (offload, sync, reverse-sync)
- Power management with fine-grained control

## Configuration Profiles

### Default (`tabelhanix`)
Standard desktop configuration with niri + DMS.

### NVIDIA (`tabelhanix-nvidia`)
Desktop with NVIDIA GPU support and gaming packages.

### Minimal (`tabelhanix-minimal`)
Minimal configuration without DMS or gaming packages.

### Laptop (`tabelhanix-laptop`)
Laptop-specific configuration with power management.

### Intel (`tabelhanix-intel`)
Desktop with Intel GPU support.

### AMD (`tabelhanix-amd`)
Desktop with AMD GPU support.

## Installation Flow

1. User runs `scripts/install.sh`
2. Script detects hardware automatically
3. User selects options via interactive prompts
4. Script generates NixOS configuration
5. Script builds and installs NixOS
6. System boots into niri with DankMaterialShell

## Security Features

### Secrets Management (sops-nix)
- Age-based encryption
- Secrets stored in `secrets/secrets.yaml`
- Key file at `/persist/secrets/age-key.txt`

### Impermanence
- Root filesystem on tmpfs
- Persistent state in `/persist`
- Automatic cleanup on boot

## Testing

### Flake Check
```bash
nix flake check --no-build
```

### Formatting
```bash
nix fmt --check .
```

### Build Test
```bash
nix build .#nixosConfigurations.tabelhanix.config.system.build.toplevel
```

## Future Improvements

- [ ] Add NixOS VM tests
- [ ] Implement rollback automation
- [ ] Add more hardware profiles
- [ ] Implement secrets rotation
- [ ] Add monitoring and alerting
