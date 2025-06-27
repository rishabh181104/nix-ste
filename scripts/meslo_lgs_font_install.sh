#!/bin/bash

# =============================
#        STECORE BANNER
# =============================
echo -e "\033[1;35m"
cat <<'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║                    🚀  STECORE  🚀                           ║
    ║                                                              ║
    ║              ⚡ Your Ultimate Dotfiles Setup ⚡               ║
    ║                                                              ║
    ║                    🎨 Powered by Hyprland 🎨                 ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "\033[0m"

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

section() { echo -e "\n${CYAN}${BOLD}==> $1${NC}"; }
success() { echo -e "${GREEN}✔ $1${NC}"; }
fail() { echo -e "${RED}✖ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

set -e

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"

section "Installing MesloLGS Nerd Font"
mkdir -p "$FONT_DIR"
temp_dir=$(mktemp -d)
cd "$temp_dir"
curl -LO "$FONT_URL" || { fail "Failed to download font."; exit 1; }
unzip Meslo.zip -d "$FONT_DIR" || { fail "Failed to unzip font."; exit 1; }
rm -f Meslo.zip
rm -rf "$temp_dir"
fc-cache -fv > /dev/null
success "MesloLGS Nerd Font installed successfully!"

