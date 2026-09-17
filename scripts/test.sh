#!/usr/bin/env bash
# TAbelhaNix — Test script
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}TAbelhaNix Test Suite${NC}"
echo ""

# Check if we're in the correct directory
if [[ ! -f flake.nix ]]; then
    echo -e "${RED}Error: flake.nix not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Test 1: Check flake syntax
echo -e "${YELLOW}Test 1: Checking flake syntax...${NC}"
if nix flake check --no-build 2>/dev/null; then
    echo -e "${GREEN}✓ Flake syntax is valid${NC}"
else
    echo -e "${RED}✗ Flake syntax check failed${NC}"
    exit 1
fi

# Test 2: Check if all required files exist
echo ""
echo -e "${YELLOW}Test 2: Checking required files...${NC}"
REQUIRED_FILES=(
    "flake.nix"
    "modules/nixos.nix"
    "modules/nvidia.nix"
    "modules/dms.nix"
    "home/default.nix"
    "home/minimal.nix"
    "scripts/install.sh"
    "scripts/test.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file missing${NC}"
        exit 1
    fi
done

# Test 3: Check if scripts are executable
echo ""
echo -e "${YELLOW}Test 3: Checking script permissions...${NC}"
if [[ -x scripts/install.sh ]]; then
    echo -e "${GREEN}✓ scripts/install.sh is executable${NC}"
else
    echo -e "${RED}✗ scripts/install.sh is not executable${NC}"
    exit 1
fi

if [[ -x scripts/test.sh ]]; then
    echo -e "${GREEN}✓ scripts/test.sh is executable${NC}"
else
    echo -e "${RED}✗ scripts/test.sh is not executable${NC}"
    exit 1
fi

# Test 4: Check Nix file syntax
echo ""
echo -e "${YELLOW}Test 4: Checking Nix file syntax...${NC}"
NIX_FILES=(
    "flake.nix"
    "modules/nixos.nix"
    "modules/nvidia.nix"
    "modules/dms.nix"
    "home/default.nix"
    "home/minimal.nix"
)

for file in "${NIX_FILES[@]}"; do
    if nix-instantiate --parse "$file" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $file syntax is valid${NC}"
    else
        echo -e "${RED}✗ $file syntax is invalid${NC}"
        exit 1
    fi
done

# Test 5: Check if flake inputs are valid
echo ""
echo -e "${YELLOW}Test 5: Checking flake inputs...${NC}"
if nix flake metadata 2>/dev/null | grep -q "Description:"; then
    echo -e "${GREEN}✓ Flake metadata is valid${NC}"
else
    echo -e "${RED}✗ Flake metadata check failed${NC}"
    exit 1
fi

# Test 6: Check if documentation exists
echo ""
echo -e "${YELLOW}Test 6: Checking documentation...${NC}"
DOC_FILES=(
    "README.md"
    "README.pt-BR.md"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    "docs/architecture.md"
)

for file in "${DOC_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${YELLOW}⚠ $file missing (optional)${NC}"
    fi
done

# Test 7: Check file sizes (sanity check)
echo ""
echo -e "${YELLOW}Test 7: Checking file sizes...${NC}"
for file in "${NIX_FILES[@]}"; do
    if [[ -s "$file" ]]; then
        size=$(wc -l < "$file")
        echo -e "${GREEN}✓ $file has $size lines${NC}"
    else
        echo -e "${RED}✗ $file is empty${NC}"
        exit 1
    fi
done

# Summary
echo ""
echo -e "${GREEN}All tests passed!${NC}"
echo ""
echo "To test the flake build, run:"
echo "  nixos-rebuild build --flake .#tabelhanix"
echo ""
echo "To test in a VM, run:"
echo "  nixos-rebuild build-vm --flake .#tabelhanix"
