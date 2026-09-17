#!/usr/bin/env bash
# TAbelhaNix — Hardware detection script
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}TAbelhaNix Hardware Detection${NC}"
echo ""

# Detect GPU
echo -e "${YELLOW}Detecting GPU...${NC}"
GPU="none"
if lspci | grep -qi "nvidia"; then
    GPU="nvidia"
    echo -e "${GREEN}✓ NVIDIA GPU detected${NC}"
elif lspci | grep -qi "intel.*vga\|intel.*3d"; then
    GPU="intel"
    echo -e "${GREEN}✓ Intel GPU detected${NC}"
elif lspci | grep -qi "amd\|radeon"; then
    GPU="amd"
    echo -e "${GREEN}✓ AMD GPU detected${NC}"
else
    echo -e "${YELLOW}⚠ No GPU detected (using none)${NC}"
fi

# Detect laptop
echo ""
echo -e "${YELLOW}Detecting form factor...${NC}"
LAPTOP=false
if [ -f /sys/class/dmi/id/product_name ]; then
    PRODUCT=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
    if echo "$PRODUCT" | grep -qi "laptop\|notebook\|thinkpad\|ideapad\|macbook\|surface"; then
        LAPTOP=true
        echo -e "${GREEN}✓ Laptop detected${NC}"
    else
        echo -e "${GREEN}✓ Desktop detected${NC}"
    fi
elif [ -f /sys/class/dmi/id/chassis_type ]; then
    CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "")
    case "$CHASSIS" in
        8|9|10|11) LAPTOP=true; echo -e "${GREEN}✓ Laptop detected${NC}" ;;
        *) echo -e "${GREEN}✓ Desktop detected${NC}" ;;
    esac
else
    echo -e "${YELLOW}⚠ Could not detect form factor${NC}"
fi

# Detect Bluetooth
echo ""
echo -e "${YELLOW}Detecting Bluetooth...${NC}"
BLUETOOTH=false
if lsusb | grep -qi "bluetooth\|wireless"; then
    BLUETOOTH=true
    echo -e "${GREEN}✓ Bluetooth detected${NC}"
elif hciconfig 2>/dev/null | grep -qi "hci"; then
    BLUETOOTH=true
    echo -e "${GREEN}✓ Bluetooth detected${NC}"
else
    echo -e "${YELLOW}⚠ No Bluetooth detected${NC}"
fi

# Detect keyboard layout
echo ""
echo -e "${YELLOW}Detecting keyboard layout...${NC}"
KEYBOARD_LAYOUT="us"
KEYBOARD_VARIANT=""
if [ -f /etc/default/keyboard ]; then
    XKB_LAYOUT=$(grep -oP 'XKBLAYOUT="\K[^"]+' /etc/default/keyboard 2>/dev/null || echo "")
    XKB_VARIANT=$(grep -oP 'XKBVARIANT="\K[^"]+' /etc/default/keyboard 2>/dev/null || echo "")
    if [ -n "$XKB_LAYOUT" ]; then
        KEYBOARD_LAYOUT="$XKB_LAYOUT"
        KEYBOARD_VARIANT="$XKB_VARIANT"
        echo -e "${GREEN}✓ Keyboard layout: $KEYBOARD_LAYOUT ${KEYBOARD_VARIANT:-default}${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Could not detect keyboard layout (using us)${NC}"
fi

# Output results as Nix options
echo ""
echo -e "${BLUE}Detected configuration:${NC}"
cat << EOF
{
  tabelhanix = {
    gpu = "$GPU";
    laptop = ${LAPTOP,,};
    bluetooth = ${BLUETOOTH,,};
    keyboardLayout = "$KEYBOARD_LAYOUT";
    ${KEYBOARD_VARIANT:+keyboardVariant = "$KEYBOARD_VARIANT";}
  };
}
EOF

echo ""
echo -e "${BLUE}Recommended configuration:${NC}"
echo "  GPU: $GPU"
echo "  Laptop: $LAPTOP"
echo "  Bluetooth: $BLUETOOTH"
echo "  Keyboard: $KEYBOARD_LAYOUT ${KEYBOARD_VARIANT:-default}"
