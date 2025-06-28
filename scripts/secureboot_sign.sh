#!/bin/sh

set -e

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
  echo -e "${GREEN}${BOLD}$1${NC}"
}

fail() {
  echo -e "\033[0;31mERROR: $1\033[0m" >&2
  exit 1
}

# Check if running as root
#
if [ "$EUID" -ne 0 ]; then
  fail "This script must be run as root. Please run: sudo $0"
  exit 1
fi

# Check if a command exists
check_command() {
  if ! command -v "$1" &> /dev/null; then
    fail "$1 is not installed. Please install it first."
    exit 1
  fi
}

# Check if system is booted in UEFI mode
if [ ! -d /sys/firmware/efi ]; then
  fail "System is not booted in UEFI mode. Please boot in UEFI mode and try again."
  exit 1
fi

# Check and mount efivarfs
if ! mountpoint -q /sys/firmware/efi/efivars; then
  section "Mounting efivarfs"
  mount -t efivarfs efivarfs /sys/firmware/efi/efivars || { fail "Failed to mount efivarfs."; exit 1; }
  success "efivarfs mounted."
fi

# Check Secure Boot status
section "Checking Secure Boot status"
if sbctl status | grep -q "Secure Boot:.*enabled"; then
  fail "Secure Boot is enabled. Please disable it in your firmware, run this script, then re-enable."
fi

# 4b. Check for Setup Mode
if ! sbctl status | grep -q "Setup Mode:.*enabled"; then
  fail "UEFI is not in Setup Mode. Please enter your firmware settings, enable Setup Mode (sometimes called Custom Mode), then run this script again."
fi

success "Secure Boot status verified."

section "Setting up boot partition"
boot_uuid=$(findmnt -n -o UUID /boot) || { fail "Failed to get boot partition UUID."; exit 1; }

# Update fstab if needed
if ! grep -q "fmask=0077,dmask=0077" /etc/fstab; then
  sed -i "s/UUID=$boot_uuid.*vfat.*/UUID=$boot_uuid \/boot vfat rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2/" /etc/fstab
fi

# Remount boot partition
umount /boot
mount -a || { fail "Failed to remount boot partition."; exit 1; }

# Set permissions
chmod 700 /boot
chmod -R 600 /boot/*
chmod 700 /boot/EFI /boot/loader 2>/dev/null || true
chmod 600 /boot/loader/random-seed 2>/dev/null || true
success "Boot partition configured."

section "Setting up Secure Boot keys"
if [ ! -d /usr/share/secureboot/keys ]; then
  sbctl create-keys || { fail "Failed to create Secure Boot keys."; exit 1; }
fi

# Remove immutable attributes from efivars
for file in /sys/firmware/efi/efivars/*; do
  [ -f "$file" ] && chattr -i "$file" 2>/dev/null || true
done

# Enroll keys
sbctl enroll-keys -m || { fail "Failed to enroll Secure Boot keys."; exit 1; }
success "Secure Boot keys enrolled."

# 7. Copy keys to NixOS default location
section "Copying keys to /usr/share/secureboot/keys/"
mkdir -p /usr/share/secureboot/keys/
cp -v /usr/share/secureboot/db.key /usr/share/secureboot/keys/db.key
cp -v /usr/share/secureboot/db.pem /usr/share/secureboot/keys/db.pem
success "Keys copied."

section "All done!"
echo
echo "Now add the following to your /etc/nixos/configuration.nix:"
echo
echo 'boot.loader.systemd-boot.enable = true;'
echo 'boot.loader.systemd-boot.secureBoot.enable = true;'
echo 'boot.loader.systemd-boot.secureBoot.keyPath = "/usr/share/secureboot/keys/db.key";'
echo 'boot.loader.systemd-boot.secureBoot.certPath = "/usr/share/secureboot/keys/db.pem";'
echo 'Before adding check if they are already present'
echo
echo "Then run: sudo nixos-rebuild switch"
echo "After rebuilding, reboot and enable Secure Boot in your firmware settings."
