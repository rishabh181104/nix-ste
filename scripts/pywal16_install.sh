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

section "Installing pywal16 in a virtual environment"

section "Updating package list and installing dependencies"
paru > /dev/null 2>&1 || warn "Package list update failed"
paru --noconfirm -S --needed python python-pip python-virtualenv git imagemagick > /dev/null 2>&1 || { fail "Failed to install dependencies."; exit 1; }
success "Dependencies installed."

section "Creating virtual environment"
rm -rf ~/pywal16-env
python -m virtualenv ~/pywal16-env > /dev/null 2>&1 || { fail "Failed to create virtual environment."; exit 1; }
source ~/pywal16-env/bin/activate || { fail "Failed to activate virtual environment."; exit 1; }
success "Virtual environment created and activated."

section "Installing pywal16 from GitHub"
pip install --upgrade pip > /dev/null 2>&1
pip install git+https://github.com/eylles/pywal16.git --no-cache-dir > /dev/null 2>&1 || { fail "Failed to install pywal16."; exit 1; }
success "pywal16 installed."

section "Verifying installation"
if wal --version > /dev/null 2>&1; then
  success "pywal16 installed! Version: $(wal --version)"
else
  fail "Installation verification failed."
  exit 1
fi

section "Configuring Fish shell"
FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"
if ! grep -q "pywal16-env" "$FISH_CONFIG"; then
  echo -e "\n# Activate pywal16 environment" >> "$FISH_CONFIG"
  echo "source ~/pywal16-env/bin/activate.fish" >> "$FISH_CONFIG"
  success "Fish shell configured."
else
  success "Fish shell already configured."
fi

echo -e "${GREEN}${BOLD}🎉 Done! pywal16 is ready!${NC}"
echo "Run 'source ~/pywal16-env/bin/activate.fish' or open a new Fish terminal."
echo "Test it with: ${CYAN}wal -i /path/to/wallpaper.jpg${NC}"
