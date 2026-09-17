#!/usr/bin/env bash
# TAbelhaNix — Rollback script
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
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

# Welcome message
gum style \
    --foreground 212 \
    --border-foreground 212 \
    --border double \
    --align center \
    --width 50 \
    --margin "1 2" \
    --padding "2 4" \
    "TAbelhaNix Rollback"

# List generations
echo ""
echo -e "${BLUE}Available generations:${NC}"

PROFILE="/nix/var/nix/profiles/system"
GENERATIONS=$(nix-env --list-generations --profile "$PROFILE" 2>/dev/null | tail -n 20)

if [ -z "$GENERATIONS" ]; then
    echo -e "${RED}No generations found${NC}"
    exit 1
fi

# Display generations
echo "$GENERATIONS"

# Get current generation
CURRENT=$(readlink -f "$PROFILE" | grep -oP '\d+' | tail -1)
echo ""
echo -e "${GREEN}Current generation: $CURRENT${NC}"

# Ask for target generation
echo ""
TARGET=$(gum input --value "$CURRENT" --placeholder "Target generation number")

if [ "$TARGET" = "$CURRENT" ]; then
    echo -e "${YELLOW}Already on generation $TARGET${NC}"
    exit 0
fi

# Confirm rollback
echo ""
echo -e "${YELLOW}Rolling back from generation $CURRENT to $TARGET${NC}"
gum confirm "Proceed with rollback?" || exit 0

# Switch generation
echo ""
echo -e "${BLUE}Switching to generation $TARGET...${NC}"

nix-env --switch-generation "$TARGET" --profile "$PROFILE"

echo ""
echo -e "${GREEN}Rollback complete!${NC}"
echo "Reboot your system to apply changes."
echo ""
echo "To rollback further, run this script again."
