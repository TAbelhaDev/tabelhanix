<div align="center">

# TabelaNix

**A NixOS flake installer for the niri + DankMaterialShell stack** — the
NixOS sibling of [TabelaArch](https://github.com/TabelaDev/tabelaarch),
targeting the same desktop stack defined in
[TabelaOS](https://github.com/TabelaDev/tabelaos).

**English** · [Português](README.pt-BR.md)

[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ianptkcs)

</div>

---

> **Status: placeholder.** No flake, no modules, no install logic yet — this
> repo exists to reserve the name and link the family together. See
> [TabelaOS](https://github.com/TabelaDev/tabelaos) for what the stack this
> will eventually install actually is.

## What this will be

A flake-based NixOS configuration covering the same ground TabelaArch's
`install/` covers for Arch, targeting:

- **niri** via [sodiboo/niri-flake](https://github.com/sodiboo/niri-flake)
- **DankMaterialShell** via its own NixOS + home-manager modules
- **NVIDIA Optimus/PRIME** via `hardware.nvidia.prime.*`, per
  [TabelaOS's `spec/optimus.md`](https://github.com/TabelaDev/tabelaos/blob/main/spec/optimus.md)
- The package set in
  [TabelaOS's `manifest/packages.toml`](https://github.com/TabelaDev/tabelaos/blob/main/manifest/packages.toml),
  using its `nixpkgs` column

TabelaArch and TabelaNix don't share install code — bash/gum and Nix modules
are different enough that forcing a shared abstraction would fight both.
They share only the target-stack definition, in TabelaOS.
