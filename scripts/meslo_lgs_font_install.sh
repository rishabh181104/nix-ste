#!/bin/sh

# Define color codes
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define logging functions
warn() {
  echo -e "\033[0;33mWARNING: $1\033[0m" >&2
}

section() {
  echo -e "${BOLD}=== $1 ===${NC}"
}

success() {
  echo -e "${GREEN}$1${NC}"
}

fail() {
  echo -e "\033[0;31mERROR: $1\033[0m" >&2
  exit 1
}

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

