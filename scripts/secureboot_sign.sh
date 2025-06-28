#!/usr/bin/env bash

set -euo pipefail

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define logging functions
warn() {
  echo -e "${YELLOW}WARNING: $1${NC}" >&2
}

section() {
  echo -e "${BOLD}=== $1 ===${NC}"
}

success() {
  echo -e "${GREEN}${BOLD}$1${NC}"
}

fail() {
  echo -e "${RED}ERROR: $1${NC}" >&2
  exit 1
}

info() {
  echo -e "${BOLD}$1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  fail "This script must be run as root. Please run: sudo $0"
fi

# Check if this is NixOS
section "Checking NixOS"
if [ ! -f /etc/os-release ] || ! grep -q "NixOS" /etc/os-release; then
  fail "This script is designed for NixOS only. Please run this on a NixOS system."
fi

# Check NixOS version
nixos_version=$(grep "VERSION=" /etc/os-release | cut -d'"' -f2)
info "NixOS version: $nixos_version"
success "NixOS detected"

# Check if required commands exist
check_command() {
  if ! command -v "$1" &> /dev/null; then
    fail "$1 is not installed. Please install it first with: nix-env -iA nixos.$1"
  fi
}

# Check for required commands
section "Checking prerequisites"
check_command "sbctl"
check_command "findmnt"
check_command "mount"
check_command "umount"
check_command "chmod"
check_command "chattr"
check_command "grep"
check_command "sed"
check_command "cp"
check_command "mkdir"
check_command "nixos-rebuild"
success "All required commands are available"

# Check if system is booted in UEFI mode
section "Checking UEFI mode"
if [ ! -d /sys/firmware/efi ]; then
  fail "System is not booted in UEFI mode. Please boot in UEFI mode and try again."
fi
success "System is booted in UEFI mode"

# Check and mount efivarfs
section "Checking efivarfs"
if ! mountpoint -q /sys/firmware/efi/efivars; then
  info "Mounting efivarfs..."
  mount -t efivarfs efivarfs /sys/firmware/efi/efivars || fail "Failed to mount efivarfs"
  success "efivarfs mounted"
else
  success "efivarfs already mounted"
fi

# Check Secure Boot status
section "Checking Secure Boot status"
if ! sbctl status &>/dev/null; then
  fail "Failed to get Secure Boot status. Make sure sbctl is properly installed."
fi

# Check if Secure Boot is enabled
if sbctl status | grep -q "Secure Boot:.*enabled"; then
  fail "Secure Boot is enabled. Please disable it in your firmware, run this script, then re-enable."
fi

# Check for Setup Mode
if ! sbctl status | grep -q "Setup Mode:.*Enabled"; then
  fail "UEFI is not in Setup Mode. Please enter your firmware settings, enable Setup Mode (sometimes called Custom Mode), then run this script again."
fi

success "Secure Boot status verified"

# Get boot partition information (NixOS specific)
section "Setting up boot partition"
boot_uuid=$(findmnt -n -o UUID /boot 2>/dev/null || findmnt -n -o UUID /boot/efi 2>/dev/null) || {
  fail "Failed to get boot partition UUID. Make sure /boot or /boot/efi is mounted."
}

boot_mount=$(findmnt -n -o TARGET /boot 2>/dev/null || findmnt -n -o TARGET /boot/efi 2>/dev/null) || {
  fail "Failed to get boot mount point."
}

info "Boot partition UUID: $boot_uuid"
info "Boot mount point: $boot_mount"

# Validate boot mount point
if [ ! -d "$boot_mount" ]; then
  fail "Boot mount point $boot_mount does not exist or is not accessible."
fi

# Check if using systemd-boot (NixOS default)
if [ -d "$boot_mount/loader" ]; then
  info "Detected systemd-boot loader"
elif [ -d "$boot_mount/EFI/nixos" ]; then
  info "Detected NixOS EFI bootloader"
else
  warn "Unknown bootloader detected. This script is optimized for systemd-boot."
fi

# Check /boot mount options
section "Checking /boot mount options"
boot_mount_opts=$(findmnt -no OPTIONS "$boot_mount" || echo "")
if ! echo "$boot_mount_opts" | grep -q "fmask=0077" || ! echo "$boot_mount_opts" | grep -q "dmask=0077"; then
  warn "Your /boot partition is not mounted with secure permissions."
  echo
  echo "To fix this, add or edit the following in your /etc/nixos/configuration.nix:"
  echo
  echo '  fileSystems."/boot" = {'
  echo '    device = "UUID='$boot_uuid'";'
  echo '    fsType = "vfat";'
  echo '    options = [ "rw" "relatime" "fmask=0077" "dmask=0077" "codepage=437" "iocharset=ascii" "shortname=mixed" "utf8" "errors=remount-ro" ];'
  echo '  };'
  echo
  echo "Then run: sudo nixos-rebuild switch"
  echo
  fail "Please update your configuration.nix and re-run this script."
fi
success "Boot partition is mounted with secure permissions."

# Create Secure Boot keys
section "Setting up Secure Boot keys"
sbctl_key_dir="/var/lib/sbctl/keys/db"

# Check if keys already exist in sbctl directory
if [ -d "$sbctl_key_dir" ] && [ -f "$sbctl_key_dir/db.key" ] && [ -f "$sbctl_key_dir/db.pem" ]; then
  info "Secure Boot keys already exist in $sbctl_key_dir"
  success "Using existing Secure Boot keys"
else
  info "Creating Secure Boot keys..."
  sbctl create-keys || fail "Failed to create Secure Boot keys"
  
  # Verify keys were created
  if [ ! -f "$sbctl_key_dir/db.key" ] || [ ! -f "$sbctl_key_dir/db.pem" ]; then
    fail "Secure Boot keys were not created properly. Check sbctl installation."
  fi
  success "Secure Boot keys created"
fi

# Remove immutable attributes from efivars
section "Preparing efivars"
for file in /sys/firmware/efi/efivars/*; do
  if [ -f "$file" ]; then
    chattr -i "$file" 2>/dev/null || true
  fi
done
success "efivars prepared"

# Enroll keys
section "Enrolling Secure Boot keys"
sbctl enroll-keys -m || fail "Failed to enroll Secure Boot keys"
success "Secure Boot keys enrolled"

# Copy keys to NixOS default location
section "Copying keys to NixOS location"

# Ensure target directory exists with proper permissions
target_dir="/usr/share/secureboot/keys"
if [ ! -d "$target_dir" ]; then
  info "Creating target directory: $target_dir"
  mkdir -p "$target_dir" || fail "Failed to create directory $target_dir"
fi

# Set proper permissions on the target directory
chmod 700 "$target_dir" || warn "Failed to set permissions on $target_dir"

# Check if keys already exist in target location
if [ -f "$target_dir/db.key" ] && [ -f "$target_dir/db.pem" ]; then
  warn "Keys already exist in $target_dir/"
  info "Existing keys:"
  ls -la "$target_dir/" 2>/dev/null || warn "Could not list existing keys"
  info "Proceeding to overwrite existing keys..."
fi

# Copy keys from sbctl directory
if [ -f "$sbctl_key_dir/db.key" ] && [ -f "$sbctl_key_dir/db.pem" ]; then
  info "Found keys in sbctl directory: $sbctl_key_dir"
  cp -v "$sbctl_key_dir/db.key" "$target_dir/db.key" || fail "Failed to copy db.key"
  cp -v "$sbctl_key_dir/db.pem" "$target_dir/db.pem" || fail "Failed to copy db.pem"
  success "Keys copied to $target_dir/"
else
  # Try to find keys in other possible locations
  key_found=false
  for search_dir in "/var/lib/sbctl/keys/db" "/usr/share/secureboot" "/etc/secureboot" "/root/.local/share/sbctl/keys/db"; do
    if [ -f "$search_dir/db.key" ] && [ -f "$search_dir/db.pem" ]; then
      info "Found keys in: $search_dir"
      cp -v "$search_dir/db.key" "$target_dir/db.key" || fail "Failed to copy db.key from $search_dir"
      cp -v "$search_dir/db.pem" "$target_dir/db.pem" || fail "Failed to copy db.pem from $search_dir"
      success "Keys copied to $target_dir/"
      key_found=true
      break
    fi
  done
  
  if [ "$key_found" = false ]; then
    fail "Secure Boot keys not found. Checked locations:"
    echo "  - /var/lib/sbctl/keys/db/"
    echo "  - /usr/share/secureboot/"
    echo "  - /etc/secureboot/"
    echo "  - /root/.local/share/sbctl/keys/db/"
    echo ""
    echo "Keys may not have been created properly. Try running 'sbctl create-keys' manually."
  fi
fi

# Verify the keys were copied successfully
if [ ! -f "$target_dir/db.key" ] || [ ! -f "$target_dir/db.pem" ]; then
  fail "Failed to copy keys to $target_dir/. Please check permissions and try again."
fi

# Set proper permissions on copied keys
chmod 600 "$target_dir/db.key" || fail "Failed to set permissions on db.key"
chmod 600 "$target_dir/db.pem" || fail "Failed to set permissions on db.pem"
success "Key permissions set"

# Verify key integrity
section "Verifying key integrity"
if [ -s "$target_dir/db.key" ] && [ -s "$target_dir/db.pem" ]; then
  success "Keys copied successfully and appear to be valid"
  info "Key files:"
  ls -la "$target_dir/" 2>/dev/null || warn "Could not list key files"
else
  fail "Keys appear to be empty or corrupted. Please check the key creation process."
fi

# Check current NixOS configuration
section "Checking NixOS configuration"
config_file="/etc/nixos/configuration.nix"
if [ -f "$config_file" ]; then
  info "Found NixOS configuration at: $config_file"
  
  # Check if Secure Boot is already configured
  if grep -q "secureBoot.enable = true" "$config_file"; then
    warn "Secure Boot appears to be already configured in your NixOS configuration."
    warn "You may want to review the existing configuration before proceeding."
  fi
else
  warn "NixOS configuration file not found at $config_file"
  warn "You may need to create it or specify the correct path."
fi

section "Script completed successfully!"
echo
info "Next steps for NixOS:"
echo
echo "1. Edit your NixOS configuration file (usually /etc/nixos/configuration.nix)"
echo "   and add the following Secure Boot configuration:"
echo
echo "   boot.loader.systemd-boot.enable = true;"
echo "   boot.loader.systemd-boot.secureBoot.enable = true;"
echo "   boot.loader.systemd-boot.secureBoot.keyPath = \"/usr/share/secureboot/keys/db.key\";"
echo "   boot.loader.systemd-boot.secureBoot.certPath = \"/usr/share/secureboot/keys/db.pem\";"
echo
echo "2. Test your configuration:"
echo "   sudo nixos-rebuild dry-activate"
echo
echo "3. Apply the configuration:"
echo "   sudo nixos-rebuild switch"
echo
echo "4. Reboot and enable Secure Boot in your firmware settings"
echo
echo "5. Verify Secure Boot is working:"
echo "   sbctl status"
echo "   sbctl verify"
echo
echo "Note: If you're using a different bootloader (like GRUB), you'll need to"
echo "configure it separately for Secure Boot support."
echo
success "NixOS Secure Boot setup complete!"
