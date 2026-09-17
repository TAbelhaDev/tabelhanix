# TAbelhaNix Troubleshooting

## Common Issues

### Build Fails

#### Error: `function called with unexpected argument 'inputs'`

**Cause:** The `modules/dms.nix` file has `inputs` in its function signature.

**Fix:** Remove `inputs` from the function parameters:
```nix
# Before
{ config, pkgs, lib, inputs, ... }:

# After
{ config, pkgs, lib, ... }:
```

#### Error: `attribute 'wayland' missing`

**Cause:** Using `wayland.windowManager.niri` instead of `programs.niri.settings`.

**Fix:** Replace `wayland.windowManager.niri` with `programs.niri.settings` (niri-flake API):
```nix
# Before
wayland.windowManager.niri = {
  enable = true;
  config = { ... };
};

# After
programs.niri.settings = {
  input = { ... };
  layout = { ... };
};
```

#### Error: `attribute 'pciBusId' missing`

**Cause:** Hardcoded PCI bus IDs in NVIDIA module.

**Fix:** The NVIDIA module now uses configurable options. Set them in your configuration:
```nix
tabelhanix.nvidia = {
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

### DMS Not Starting

#### Check if DMS is enabled

```bash
nix eval .#nixosConfigurations.tabelhanix.config.programs.dank-material-shell.enable
```

#### Check systemd service

```bash
systemctl --user status dms.service
journalctl --user -u dms.service
```

#### Restart DMS

```bash
systemctl --user restart dms.service
```

### Niri Not Starting

#### Check if niri is enabled

```bash
nix eval .#nixosConfigurations.tabelhanix.config.programs.niri.enable
```

#### Validate niri configuration

```bash
niri validate
```

#### Check niri logs

```bash
journalctl --user -u niri.service
```

### Graphics Issues

#### Check GPU

```bash
lspci | grep -E "VGA|3D"
```

#### Check OpenGL

```bash
glxinfo | head -20
```

#### Check VA-API

```bash
vainfo
```

### Bluetooth Issues

#### Check Bluetooth service

```bash
systemctl status bluetooth
bluetoothctl show
```

#### Pair device

```bash
bluetoothctl
scan on
pair XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

## Debugging

### Check system logs

```bash
# System logs
journalctl -b -p 3

# User logs
journalctl --user -b

# DMS logs
journalctl --user -u dms.service

# Niri logs
journalctl --user -u niri.service
```

### Check NixOS generation

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Switch to previous generation
sudo nix-env --switch-generation <number> --profile /nix/var/nix/profiles/system
```

### Rollback

```bash
# Use the rollback script
./scripts/rollback.sh

# Or manually
sudo nix-env --rollback
```

## Performance Issues

### High CPU usage

```bash
# Check running processes
top -o %CPU

# Check systemd services
systemctl list-units --type=service --state=running
```

### Memory usage

```bash
# Check memory
free -h

# Check swap
swapon --show
```

### Disk space

```bash
# Check disk usage
df -h

# Check Nix store
du -sh /nix/store

# Garbage collection
sudo nix-collect-garbage -d
```

## Configuration Issues

### Options not taking effect

Check if options are set correctly:
```bash
nix eval .#nixosConfigurations.tabelhanix.config.tabelhanix.gpu
nix eval .#nixosConfigurations.tabelhanix.config.tabelhanix.laptop
```

### Packages not installed

Check if packages are in the right layer:
- System packages: `modules/nixos.nix`
- User packages: `home/default.nix`
- DMS packages: `modules/dms.nix`

### Conflicts between modules

Check for duplicate definitions:
```bash
nix-instantiate --parse modules/nixos.nix
nix-instantiate --parse modules/dms.nix
```

## Getting Help

### Documentation

- [Usage Guide](usage.md)
- [Architecture](architecture.md)

### Community

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://reddit.com/r/nixos)
- [DankLinux Discord](https://discord.gg/ppWTpKmPgT)

### Bug Reports

Open an issue on GitHub with:
1. Description of the problem
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. System information (`nix-info -m`)
