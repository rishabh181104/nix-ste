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

# Base paths
SOURCE_BASE="$HOME/nix-ste"
TARGET_BASE="$HOME/.config"
TARGET_FOR_NIXOS="/etc"

# Directories to link
DIRS_TO_REPLACE=(alacritty foot mako rofi wal fastfetch hypr waybar fish kitty qtile wlogout picom nvim)
DIRS_TO_REPLACE_FOR_NIXOS=(nixos)

# Files to link
FILES_TO_REPLACE=(starship.toml)

section "Linking Directories"
for DIR_NAME in "${DIRS_TO_REPLACE[@]}"; do
  SRC="$SOURCE_BASE/$DIR_NAME"
  DEST="$TARGET_BASE/$DIR_NAME"
  if [ ! -d "$SRC" ]; then
    warn "Source directory does not exist: $SRC"
    continue
  fi
  [ -L "$DEST" ] && rm "$DEST"
  [ -d "$DEST" ] && rm -rf "$DEST"
  ln -s "$SRC" "$DEST"
  success "Linked $SRC to $DEST"
done

section "Linking Directories For Nix OS"
for DIR_NAME in "${DIRS_TO_REPLACE_FOR_NIXOS[@]}"; do
  SRC="$SOURCE_BASE/$DIR_NAME"
  DEST="$TARGET_FOR_NIXOS/$DIR_NAME"
  if [ ! -Resource: if [ ! -d "$SRC" ]; then
    warn "Source directory does not exist: $SRC"
    continue
  fi
  [ -L "$DEST" ] && sudo rm "$DEST"
  [ -d "$DEST" ] && sudo rm -rf "$DEST"
  sudo ln -s "$SRC" "$DEST"
  success "Linked $SRC to $DEST"
done

section "Linking Files"
for FILE_NAME in "${FILES_TO_REPLACE[@]}"; do
  SRC="$SOURCE_BASE/$FILE_NAME"
  DEST="$TARGET_BASE/$FILE_NAME"
  if [ ! -f "$SRC" ]; then
    warn "Source file does not exist: $SRC"
    continue
  fi
  [ -L "$DEST" ] && rm "$DEST"
  [ -f "$DEST" ] && rm -f "$DEST"
  ln -s "$SRC" "$DEST"
  success "Linked $SRC to $DEST"
done

echo -e "${GREEN}${BOLD}All config files and directories are now linked!${NC}"
