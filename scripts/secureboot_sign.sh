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

# Check if running as root
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
sb_status=$(sbctl status 2>/dev/null) || { fail "Failed to get Secure Boot status. Is sbctl installed?"; exit 1; }

if echo "$sb_status" | grep -q "Secure Boot:.*Enabled"; then
  fail "Secure Boot is enabled. Please disable it in your UEFI firmware settings."
  echo "Steps:"
  echo "1. Reboot your system"
  echo "2. Enter UEFI settings (usually F2, Del, or F12)"
  echo "3. Find Secure Boot settings"
  echo "4. Disable Secure Boot"
  echo "5. Save and exit"
  echo "6. Run this script again"
  exit 1
fi

if ! echo "$sb_status" | grep -q "Setup Mode:.*Enabled"; then
  fail "Setup Mode is not enabled. Please enable it in your UEFI firmware settings."
  echo "Steps:"
  echo "1. Reboot your system"
  echo "2. Enter UEFI settings (usually F2, Del, or F12)"
  echo "3. Find Secure Boot settings"
  echo "4. Enable Setup Mode (or Custom/User Mode)"
  echo "5. Save and exit"
  echo "6. Run this script again"
  exit 1
fi

success "Secure Boot status verified."

section "Installing required packages"
pacman -S --needed --noconfirm sbctl mokutil openssl linux-headers refind || { fail "Failed to install required packages."; exit 1; }
success "Required packages installed."

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

section "Setting up pacman hooks"
mkdir -p /etc/pacman.d/hooks

cat << EOF > /etc/pacman.d/hooks/99-secureboot.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = refind

[Action]
Description = Signing kernel and bootloader for Secure Boot...
When = PostTransaction
Exec = /usr/bin/sbctl sign -s /boot/EFI/refind/refind_x64.efi -s /boot/EFI/Linux/arch-linux.efi
EOF
success "Pacman hooks configured."

section "Setting up kernel signing"
mkdir -p /etc/dkms
if [ ! -f /etc/dkms/module.key ]; then
  openssl req -new -x509 -newkey rsa:2048 -keyout /etc/dkms/module.key \
    -out /etc/dkms/module.crt -nodes -days 3650 \
    -subj "/CN=Module Signing Key" -outform DER
  chmod 600 /etc/dkms/module.key /etc/dkms/module.crt
fi

# Enroll module signing key
mokutil --import /etc/dkms/module.crt || { fail "Failed to enroll module signing key."; exit 1; }

# Update mkinitcpio.conf if needed
if ! grep -q "sd-encrypt" /etc/mkinitcpio.conf; then
  sed -i 's/HOOKS=(/HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap consolefont block sd-encrypt filesystems fsck/' /etc/mkinitcpio.conf
fi

# Update linux.preset
root_uuid=$(findmnt -n -o UUID /) || { fail "Failed to get root partition UUID."; exit 1; }

cat << EOF > /etc/mkinitcpio.d/linux.preset
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default')
default_uki="/boot/EFI/Linux/arch-linux.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp root=UUID=$root_uuid rw"
EOF

# Generate and sign UKI
mkinitcpio -P || { fail "Failed to generate UKI."; exit 1; }
success "Kernel signing configured."

echo -e "${GREEN}${BOLD}Secure Boot setup completed successfully!${NC}"
echo "Please reboot your system and enroll the MOK in the firmware when prompted."
