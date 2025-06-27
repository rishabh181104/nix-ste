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

REPO_URL="https://gitlab.com/phoneybadger/pokemon-colorscripts.git"
CLONE_DIR="/tmp/pokemon-colorscripts"
INSTALL_SCRIPT="./install.sh"

# Check if git is installed
if ! command -v git &> /dev/null; then
  fail "git is not installed. Please install git and try again."
  exit 1
fi

section "Cloning pokemon-colorscripts repository"
git clone "$REPO_URL" "$CLONE_DIR" || { fail "Failed to clone repository."; exit 1; }
success "Repository cloned."

section "Running installation"
cd "$CLONE_DIR"
if [ ! -f "$INSTALL_SCRIPT" ]; then
  fail "install.sh not found in the repository."
  exit 1
fi

chmod +x "$INSTALL_SCRIPT"
"$INSTALL_SCRIPT" || { fail "Installation failed."; exit 1; }
success "Installation completed."

section "Cleaning up"
cd /tmp
rm -rf "$CLONE_DIR"
success "Cleanup complete."

section "Verifying installation"
if command -v pokemon-colorscripts &> /dev/null; then
  success "pokemon-colorscripts installed successfully!"
  echo "Try running: pokemon-colorscripts --random"
else
  fail "Installation verification failed."
  exit 1
fi
