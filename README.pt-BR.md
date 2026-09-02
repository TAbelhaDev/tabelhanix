<div align="center">

# TAbelhaNix

**Um instalador NixOS via flake pro stack niri + DankMaterialShell** — o
irmão NixOS do [TAbelhaArch](https://github.com/TAbelhaDev/tabelhaarch), com o
mesmo stack alvo definido no [TAbelhaOS](https://github.com/TAbelhaDev/tabelhaos).

[English](README.md) · **Português**

[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ianptkcs)

</div>

---

> **Status: placeholder.** Sem flake, sem módulos, sem lógica de instalação
> ainda — este repo existe pra reservar o nome e linkar a família. Ver o
> [TAbelhaOS](https://github.com/TAbelhaDev/tabelhaos) pra saber o que é o
> stack que isto vai instalar quando existir.

## O que isto vai ser

Uma configuração NixOS via flake cobrindo o mesmo terreno que o `install/`
do TAbelhaArch cobre pro Arch, tendo como alvo:

- **niri** via [sodiboo/niri-flake](https://github.com/sodiboo/niri-flake)
- **DankMaterialShell** via seus próprios módulos NixOS + home-manager
- **NVIDIA Optimus/PRIME** via `hardware.nvidia.prime.*`, conforme o
  [`spec/optimus.md`](https://github.com/TAbelhaDev/tabelhaos/blob/main/spec/optimus.md)
  do TAbelhaOS
- O conjunto de pacotes em
  [`manifest/packages.toml`](https://github.com/TAbelhaDev/tabelhaos/blob/main/manifest/packages.toml)
  do TAbelhaOS, usando a coluna `nixpkgs`

TAbelhaArch e TAbelhaNix não compartilham código de instalação — bash/gum e
módulos Nix são diferentes o suficiente pra que forçar uma abstração
compartilhada prejudicasse os dois. Eles compartilham só a definição do
stack alvo, no TAbelhaOS.
