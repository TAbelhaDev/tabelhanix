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

> **Status: em desenvolvimento.** Flake e módulos básicos criados.

## Como usar

### Instalação interativa

```bash
# Clonar o repositório
git clone https://github.com/TAbelhaDev/tabelhanix.git
cd tabelhanix

# Executar o instalador
./scripts/install.sh
```

### Instalação manual

```bash
# Copiar configuração
sudo cp modules/nixos.nix /etc/nixos/tabelhanix/
sudo cp modules/nvidia.nix /etc/nixos/tabelhanix/  # opcional

# Gerar configuração de hardware
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

# Editar /etc/nixos/configuration.nix conforme necessário

# Construir e instalar
sudo nixos-rebuild switch
```

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

## Configurações disponíveis

| Configuração | Descrição |
|---------------|-----------|
| `tabelhanix` | Configuração desktop padrão |
| `tabelhanix-nvidia` | Desktop com suporte a GPU NVIDIA |
| `tabelhanix-minimal` | Configuração mínima |
| `tabelhanix-laptop` | Configuração específica para laptop |
| `tabelhanix-intel` | Desktop com GPU Intel |
| `tabelhanix-amd` | Desktop com GPU AMD |

## Documentação

- [Guia de Uso](docs/usage.md)
- [Arquitetura](docs/architecture.md)

TAbelhaArch e TAbelhaNix não compartilham código de instalação — bash/gum e
módulos Nix são diferentes o suficiente pra que forçar uma abstração
compartilhada prejudicasse os dois. Eles compartilham só a definição do
stack alvo, no TAbelhaOS.
