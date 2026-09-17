# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- CI/CD with GitHub Actions (ci.yml, format.yml, release.yml, update.yml)
- Secrets management with sops-nix (modules/sops.nix)
- Impermanence support (modules/impermanence.nix)
- Hardware detection script (scripts/hardware-detect.sh)
- Rollback script (scripts/rollback.sh)
- NixOS VM tests (tests/default.nix) with proper test framework
- Flake checks: VM tests for default configuration
- Troubleshooting documentation (docs/troubleshooting.md)
- Updated architecture documentation
- `keyboardLayout` and `keyboardVariant` options wired to console and niri

### Fixed

- Remove `inputs` from DMS module function signature (was breaking evaluation)
- Replace `wayland.windowManager.niri` with `programs.niri.settings` (niri-flake API)
- Remove hardcoded PCI bus IDs from NVIDIA module (now configurable)
- Remove `dynamicBoost` and `nvswitch` (laptop/multi-GPU specific)
- Remove `hardware` input from flake (was unused, wasted bandwidth)
- Remove duplicate packages between nixos.nix, home/default.nix, and dms.nix
- Remove startup commands (waybar, dunst) that conflicted with DMS
- Conditionalize hardware modules with `lib.mkIf`
- Conditionalize services (PostgreSQL, Redis, libvirtd, Steam) with options
- **CRITICAL**: Move `imports` out of `config` block in sops.nix and impermanence.nix
- Replace deprecated `hardware.opengl` with `hardware.graphics` (NixOS 24.05+)
- Remove duplicate `brightnessctl` package (hardware/laptop.nix + nixos.nix)
- Fix install.sh mkdir/cp ordering (directory created after file copy)
- Wire `persistHome` option in impermanence.nix
- Rewrite tests/default.nix with proper NixOS VM test framework
- Remove unused `dynamicBoost` option from nvidia.nix
- Remove redundant `dotfiles.nix` import from home/minimal.nix

### Changed

- Custom options module (`modules/options.nix`) for `tabelhanix.*` settings
- Refactored nixos.nix to use `lib.mkDefault` and `lib.optionals`
- Simplified DMS module (removed duplicate package list)
- Updated flake configurations to use new options system
- Improved installer with hardware detection
- Flake DRY: helper function `mkNixosConfig` reduces configuration duplication
- Wire `keyboardLayout`/`keyboardVariant` via `osConfig` in home-manager
- Pass `sops-nix` and `impermanence` inputs via `specialArgs` to modules
