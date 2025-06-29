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

section "Installing pywal16 in a virtual environment"


section "Creating virtual environment"
rm -rf ~/pywal16-env
virtualenv ~/pywal16-env > /dev/null 2>&1 || { fail "Failed to create virtual environment."; exit 1; }
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
