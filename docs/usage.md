# TAbelhaNix Usage Guide

## Installation

### Interactive Installation

```bash
# Clone the repository
git clone https://github.com/TAbelhaDev/tabelhanix.git
cd tabelhanix

# Run the installer
./scripts/install.sh
```

### Manual Installation

```bash
# Copy configuration
sudo cp modules/nixos.nix /etc/nixos/tabelhanix/
sudo cp modules/nvidia.nix /etc/nixos/tabelhanix/  # optional
sudo cp modules/dms.nix /etc/nixos/tabelhanix/  # optional

# Generate hardware configuration
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

# Edit /etc/nixos/configuration.nix as needed

# Build and install
sudo nixos-rebuild switch
```

## Available Configurations

### Default Configuration (`tabelhanix`)

Standard desktop configuration with:
- Niri window manager
- DankMaterialShell
- Full package set
- Home Manager with dotfiles

### NVIDIA Configuration (`tabelhanix-nvidia`)

Desktop with NVIDIA GPU support:
- NVIDIA Optimus/PRIME
- Open-source kernel module
- Power management
- Suspend/resume support

### Minimal Configuration (`tabelhanix-minimal`)

Minimal configuration with:
- Niri window manager
- Basic package set
- Minimal Home Manager configuration

### Laptop Configuration (`tabelhanix-laptop`)

Laptop-specific configuration:
- Power management (TLP)
- Battery monitoring
- Brightness control
- Touchpad support

### Intel GPU Configuration (`tabelha-intel`)

Desktop with Intel GPU:
- Intel media driver
- VA-API support
- Hardware acceleration

### AMD GPU Configuration (`tabelhanix-amd`)

Desktop with AMD GPU:
- AMDVLK driver
- RADV Vulkan driver
- Hardware acceleration

## Building Specific Configurations

```bash
# Build default configuration
sudo nixos-rebuild switch --flake .#tabelhanix

# Build NVIDIA configuration
sudo nixos-rebuild switch --flake .#tabelhanix-nvidia

# Build minimal configuration
sudo nixos-rebuild switch --flake .#tabelhanix-minimal

# Build laptop configuration
sudo nixos-rebuild switch --flake .#tabelhanix-laptop

# Build Intel configuration
sudo nixos-rebuild switch --flake .#tabelhanix-intel

# Build AMD configuration
sudo nixos-rebuild switch --flake .#tabelhanix-amd
```

## Testing in VM

```bash
# Build VM
nixos-rebuild build-vm --flake .#tabelhanix

# Run VM
./result/bin/run-tabelhanix-vm
```

## Testing Flake

```bash
# Run all tests
./scripts/test.sh

# Check flake syntax
nix flake check --no-build

# Show flake metadata
nix flake metadata
```

## Development

### Entering Development Shell

```bash
# Enter development shell
nix develop

# Or with nix-shell
nix-shell -p nixfmt-rfc-style nil nixpkgs-fmt
```

### Formatting Code

```bash
# Format all Nix files
nix fmt

# Format specific file
nixfmt modules/nixos.nix
```

### Linting

```bash
# Check Nix file syntax
nix-instantiate --parse modules/nixos.nix > /dev/null

# Check all Nix files
find . -name "*.nix" -exec nix-instantiate --parse {} > /dev/null \;
```

## Updating

### Updating Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input niri
nix flake lock --update-input DankMaterialShell
```

### Updating System

```bash
# Rebuild with updated inputs
sudo nixos-rebuild switch --flake .
```

## Rollback

### Rolling Back to Previous Generation

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Switch to previous generation
sudo nix-env --switch-generation <generation-number> --profile /nix/var/nix/profiles/system

# Or reboot and select previous generation in boot menu
```

### Rolling Back via Boot Menu

1. Reboot system
2. Select "Advanced options" in boot menu
3. Select previous generation
4. Boot into previous configuration

## Troubleshooting

### Common Issues

#### Build Fails

```bash
# Check flake syntax
nix flake check --no-build

# Check Nix file syntax
nix-instantiate --parse modules/nixos.nix

# Check for missing dependencies
nix flake metadata
```

#### DMS Not Starting

```bash
# Check if DMS is enabled
nix eval .#nixosConfigurations.tabelhanix.config.programs.dank-material-shell.enable

# Check systemd service
systemctl --user status dms.service

# Restart DMS
systemctl --user restart dms.service
```

#### Niri Not Starting

```bash
# Check if niri is enabled
nix eval .#nixosConfigurations.tabelhanix.config.programs.niri.enable

# Check niri configuration
cat ~/.config/niri/config.kdl

# Test niri configuration
niri validate
```

#### Graphics Issues

```bash
# Check GPU
lspci | grep -E "VGA|3D"

# Check OpenGL
glxinfo | head -20

# Check VA-API
vainfo
```

### Getting Help

```bash
# Check system logs
journalctl -b -p 3

# Check user logs
journalctl --user -b

# Check DMS logs
journalctl --user -u dms.service

# Check niri logs
journalctl --user -u niri.service
```

## Uninstalling

### Removing TAbelhaNix

```bash
# Switch to previous generation
sudo nix-env --rollback

# Or reinstall NixOS
sudo nixos-install --flake .
```

### Cleaning Old Generations

```bash
# Remove old generations
sudo nix-collect-garbage -d

# Remove old profiles
sudo nix-env --delete-generations old
```
