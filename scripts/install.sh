#!/usr/bin/env bash
# TAbelhaNix — Interactive installer
# Can run from live USB or existing NixOS
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}This script should not be run as root${NC}"
    exit 1
fi

# Check if we're on NixOS
if [[ ! -f /etc/NIXOS ]]; then
    echo -e "${RED}This script must be run on NixOS (live USB or installed)${NC}"
    exit 1
fi

# Check if gum is installed, install if not
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}Installing gum...${NC}"
    nix-shell -p gum --run "echo 'gum installed'"
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Welcome
gum style \
    --foreground 212 \
    --border-foreground 212 \
    --border double \
    --align center \
    --width 50 \
    --margin "1 2" \
    --padding "2 4" \
    "TAbelhaNix Installer" \
    "NixOS + niri + DankMaterialShell"

gum confirm "Ready to install TAbelhaNix?" || exit 0

# Hardware detection
echo ""
echo -e "${BLUE}Detecting hardware...${NC}"
DETECTED=$("$SCRIPT_DIR/hardware-detect.sh" 2>/dev/null || echo "")
DETECTED_GPU=$(echo "$DETECTED" | grep -oP 'gpu = "\K[^"]+' || echo "none")
DETECTED_LAPTOP=$(echo "$DETECTED" | grep -oP 'laptop = \K[a-z]+' || echo "false")
DETECTED_BLUETOOTH=$(echo "$DETECTED" | grep -oP 'bluetooth = \K[a-z]+' || echo "false")
echo -e "${GREEN}Detected: GPU=$DETECTED_GPU, Laptop=$DETECTED_LAPTOP, Bluetooth=$DETECTED_BLUETOOTH${NC}"

# User configuration
echo ""
echo -e "${BLUE}User Configuration${NC}"
USERNAME=$(gum input --value "tabelha" --placeholder "Username")
HOSTNAME=$(gum input --value "tabelhanix" --placeholder "Hostname")
TIMEZONE=$(gum input --value "America/Sao_Paulo" --placeholder "Timezone")

# GPU selection
echo ""
echo -e "${BLUE}GPU Configuration${NC}"
GPU=$(gum choose --header "Select GPU:" --default "$DETECTED_GPU" none intel amd nvidia)

# Feature selection
echo ""
echo -e "${BLUE}Feature Selection${NC}"
LAPTOP=$(gum confirm "Laptop optimizations?" --default=$([ "$DETECTED_LAPTOP" = "true" ] && echo "true" || echo "false") && echo "true" || echo "false")
BLUETOOTH=$(gum confirm "Bluetooth support?" --default=$([ "$DETECTED_BLUETOOTH" = "true" ] && echo "true" || echo "false") && echo "true" || echo "false")
GAMING=$(gum confirm "Gaming packages?" && echo "true" || echo "false")
DEV=$(gum confirm "Development tools?" && echo "true" || echo "false")
VM=$(gum confirm "Virtualization?" && echo "true" || echo "false")
FLATPAK=$(gum confirm "Flatpak support?" && echo "true" || echo "false")
POSTGRESQL=$(gum confirm "PostgreSQL server?" && echo "true" || echo "false")
REDIS=$(gum confirm "Redis server?" && echo "true" || echo "false")

# Summary
echo ""
echo -e "${GREEN}Installation Summary${NC}"
echo "Username: $USERNAME"
echo "Hostname: $HOSTNAME"
echo "Timezone: $TIMEZONE"
echo "GPU: $GPU"
echo "Laptop: $LAPTOP, Bluetooth: $BLUETOOTH"
echo "Gaming: $GAMING, Dev: $DEV, VM: $VM"
echo "Flatpak: $FLATPAK, PostgreSQL: $POSTGRESQL, Redis: $REDIS"

gum confirm "Proceed with installation?" || exit 0

# Create NixOS configuration
echo ""
echo -e "${BLUE}Generating NixOS configuration...${NC}"

sudo mkdir -p /etc/nixos/tabelhanix/hardware

# Copy modules
sudo cp "$SCRIPT_DIR"/../modules/nixos.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/options.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/dms.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/nvidia.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/sops.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/impermanence.nix /etc/nixos/tabelhanix/
sudo cp "$SCRIPT_DIR"/../modules/hardware/*.nix /etc/nixos/tabelhanix/hardware/

# Generate hardware configuration
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

# Generate main configuration
cat > /etc/nixos/configuration.nix << EOF
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./tabelhanix/nixos.nix
    ./tabelhanix/hardware/intel.nix
    ./tabelhanix/hardware/amd.nix
    ./tabelhanix/hardware/laptop.nix
  ];

  tabelhanix = {
    username = "$USERNAME";
    hostname = "$HOSTNAME";
    timezone = "$TIMEZONE";
    gpu = "$GPU";
    laptop = ${LAPTOP,,};
    bluetooth = ${BLUETOOTH,,};
    gaming = ${GAMING,,};
    dev = ${DEV,,};
    vm = ${VM,,};
    flatpak = ${FLATPAK,,};
    postgresql = ${POSTGRESQL,,};
    redis = ${REDIS,,};
  };
}
EOF

# Build and install
echo ""
echo -e "${BLUE}Building NixOS configuration...${NC}"
sudo nixos-rebuild switch

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo "Reboot your system to start using TAbelhaNix."
echo ""
echo "After reboot:"
echo "  1. Login as $USERNAME"
echo "  2. Start niri with 'niri-session'"
echo "  3. DankMaterialShell will load automatically"
