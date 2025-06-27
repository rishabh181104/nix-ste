#!/bin/sh

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

