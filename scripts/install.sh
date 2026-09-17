#!/usr/bin/env bash
# TAbelhaNix — Interactive installer
set -euo pipefail

# Colors
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
    echo -e "${RED}This script must be run on NixOS${NC}"
    exit 1
fi

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}Installing gum...${NC}"
    nix-shell -p gum --run "echo 'gum installed'"
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Welcome message
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

# Configuration
gum confirm "Ready to install TAbelhaNix?" || exit 0

# Hardware detection
echo ""
echo -e "${BLUE}Detecting hardware...${NC}"

# Run hardware detection script
DETECTED=$("$SCRIPT_DIR/hardware-detect.sh" 2>/dev/null || echo "")

# Parse detected values
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

# Configuration profile
echo ""
echo -e "${BLUE}Configuration Profile${NC}"
PROFILE=$(gum choose --header "Select profile:" default minimal full)

# Summary
echo ""
echo -e "${GREEN}Installation Summary${NC}"
echo "Username: $USERNAME"
echo "Hostname: $HOSTNAME"
echo "Timezone: $TIMEZONE"
echo "GPU: $GPU"
echo "Laptop: $LAPTOP"
echo "Bluetooth: $BLUETOOTH"
echo "Gaming: $GAMING"
echo "Development: $DEV"
echo "Virtualization: $VM"
echo "Flatpak: $FLATPAK"
echo "PostgreSQL: $POSTGRESQL"
echo "Redis: $REDIS"
echo "Profile: $PROFILE"

gum confirm "Proceed with installation?" || exit 0

# Create NixOS configuration
echo ""
echo -e "${BLUE}Generating NixOS configuration...${NC}"

# Create configuration directory
sudo mkdir -p /etc/nixos/tabelhanix

# Create hardware directory if it doesn't exist
sudo mkdir -p /etc/nixos/tabelhanix/hardware

# Copy modules
sudo cp modules/nixos.nix /etc/nixos/tabelhanix/
sudo cp modules/options.nix /etc/nixos/tabelhanix/
sudo cp modules/dms.nix /etc/nixos/tabelhanix/
sudo cp modules/nvidia.nix /etc/nixos/tabelhanix/
sudo cp modules/sops.nix /etc/nixos/tabelhanix/
sudo cp modules/impermanence.nix /etc/nixos/tabelhanix/
sudo cp modules/hardware/*.nix /etc/nixos/tabelhanix/hardware/

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

  # Override settings
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
echo ""
echo "Useful commands:"
echo "  - Hardware detection: ./scripts/hardware-detect.sh"
echo "  - Rollback: ./scripts/rollback.sh"
echo "  - Test flake: ./scripts/test.sh"
