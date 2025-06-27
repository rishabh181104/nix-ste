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

# Ensure root privileges
if [ "$(id -u)" -ne 0 ]; then
  warn "Script requires root privileges. Re-executing with sudo..."
  exec sudo "$0" "$@"
fi

section "Detecting active network connections"
wifi_info=$(nmcli -t -f NAME,DEVICE,TYPE con show --active | awk -F: '$3=="802-11-wireless" || $3=="wifi" {print $0}' || true)
eth_info=$(nmcli -t -f NAME,DEVICE,TYPE con show --active | awk -F: '$3=="802-3-ethernet" || $3=="ethernet" {print $0}' || true)

wifi_conn=""
wifi_dev=""
eth_conn=""
eth_dev=""

if [ -n "$wifi_info" ]; then
  wifi_conn=$(echo "$wifi_info" | cut -d: -f1)
  wifi_dev=$(echo "$wifi_info" | cut -d: -f2)
fi
if [ -n "$eth_info" ]; then
  eth_conn=$(echo "$eth_info" | cut -d: -f1)
  eth_dev=$(echo "$eth_info" | cut -d: -f2)
fi

if [ -z "$wifi_conn" ] && [ -z "$eth_conn" ]; then
  warn "No active Wi-Fi or Ethernet connections found."
  exit 0
fi

# Optimize Wi-Fi
if [ -n "$wifi_conn" ]; then
  section "Optimizing Wi-Fi: $wifi_conn ($wifi_dev)"
  iw dev "$wifi_dev" set power_save off 2>/dev/null && success "Disabled Wi-Fi power saving for $wifi_dev" || warn "Failed to disable power saving for $wifi_dev (may not be supported)"
  if lsmod | grep -q iwlwifi; then
    echo "options iwlwifi power_save=0" > /etc/modprobe.d/iwlwifi.conf
    success "Set permanent Wi-Fi power saving disable in /etc/modprobe.d/iwlwifi.conf"
  fi
  nmcli connection modify "$wifi_conn" ipv4.dns "1.1.1.1,8.8.8.8" || warn "Failed to set IPv4 DNS for $wifi_conn"
  nmcli connection modify "$wifi_conn" ipv6.dns "2606:4700:4700::1111,2001:4860:4860::8888" || warn "Failed to set IPv6 DNS for $wifi_conn"
  success "Set Cloudflare (primary) and Google (secondary) DNS servers for $wifi_conn"
fi

# Optimize Ethernet
if [ -n "$eth_conn" ]; then
  section "Optimizing Ethernet: $eth_conn ($eth_dev)"
  nmcli connection modify "$eth_conn" ipv4.dns "1.1.1.1,8.8.8.8" || warn "Failed to set IPv4 DNS for $eth_conn"
  nmcli connection modify "$eth_conn" ipv6.dns "2606:4700:4700::1111,2001:4860:4860::8888" || warn "Failed to set IPv6 DNS for $eth_conn"
  success "Set Cloudflare (primary) and Google (secondary) DNS servers for $eth_conn"
fi

section "Restarting NetworkManager"
systemctl restart NetworkManager && success "NetworkManager restarted successfully" || fail "Failed to restart NetworkManager"
sleep 3

# Reactivate connections
[ -n "$wifi_conn" ] && nmcli connection up "$wifi_conn" && success "Reactivated Wi-Fi: $wifi_conn" || warn "Failed to reactivate $wifi_conn"
[ -n "$eth_conn" ] && nmcli connection up "$eth_conn" && success "Reactivated Ethernet: $eth_conn" || warn "Failed to reactivate $eth_conn"

section "Testing connectivity"
ping -c 4 8.8.8.8 && success "Ping test successful!" || warn "Ping test failed; check network status."

echo -e "${GREEN}${BOLD}Network optimization complete!${NC}"
