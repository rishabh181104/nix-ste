#!/usr/bin/env bash

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

# Ensure we're in a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not in a Git repository. Run this script from a repository directory."
  exit 1
fi

# Prompt for GitHub username
read -p "Enter your GitHub username: " github_user
if [ -z "$github_user" ]; then
  echo "Error: Username cannot be empty."
  exit 1
fi

# Check if SSH setup is already complete
ssh_key="$HOME/.ssh/id_rsa"
ssh_configured=true
bash_config="$HOME/.bashrc"

# Check if SSH key exists
if [ ! -f "$ssh_key" ]; then
  ssh_configured=false
fi

# Check if remote URL is already SSH
current_url=$(git remote get-url origin 2>/dev/null)
expected_url_prefix="git@github.com:$github_user/"
if [[ ! "$current_url" =~ ^"$expected_url_prefix" ]]; then
  ssh_configured=false
fi

# Check if SSH agent is configured in Bash
if ! grep -q "ssh-agent" "$bash_config" 2>/dev/null; then
  ssh_configured=false
fi

# Test SSH connection
ssh -T git@github.com >/dev/null 2>&1
if [ $? -ne 1 ]; then
  ssh_configured=false
fi

# Exit if everything is set up
if [ "$ssh_configured" = true ]; then
  echo "SSH setup is already complete for $github_user."
  echo "Test with 'lazygit': stage (s), commit (c), push (p)."
  exit 0
fi

# Prompt for repository name
read -p "Enter your GitHub repository name (e.g., my-repo): " github_repo
if [ -z "$github_repo" ]; then
  echo "Error: Repository name cannot be empty."
  exit 1
fi

# Prompt for SSH passphrase
read -sp "Enter a passphrase for the SSH key (cannot be empty): " passphrase
echo
read -sp "Confirm passphrase: " passphrase_confirm
echo
if [ -z "$passphrase" ] || [ "$passphrase" != "$passphrase_confirm" ]; then
  echo "Error: Passphrase cannot be empty and must match confirmation."
  exit 1
fi

# Generate RSA SSH key with passphrase
if [ ! -f "$ssh_key" ]; then
  echo "Generating RSA SSH key..."
  ssh-keygen -t rsa -b 4096 -C "lazygit@nixos" -f "$ssh_key" -N "$passphrase"
  if [ $? -ne 0 ]; then
    echo "Failed to generate RSA SSH key."
    exit 1
  fi
  chmod 600 "$ssh_key"
  chmod 644 "$ssh_key.pub"
else
  echo "RSA SSH key already exists at $ssh_key."
fi

# Copy public key to clipboard (use xclip on NixOS)
if command -v xclip &>/dev/null; then
  xclip -sel clip < "$ssh_key.pub"
  if [ $? -eq 0 ]; then
    echo "SSH public key copied to clipboard."
  else
    echo "Failed to copy public key. Run 'cat $ssh_key.pub' and copy manually."
  fi
else
  echo "xclip not found. Run 'cat $ssh_key.pub' and copy manually."
fi

# Update remote URL to SSH
ssh_url="git@github.com:$github_user/$github_repo.git"
git remote set-url origin "$ssh_url"
if [ $? -eq 0 ]; then
  echo "Updated remote URL to $ssh_url"
else
  echo "Failed to update remote URL."
  exit 1
fi

# Configure SSH agent in Bash config
if ! grep -q "ssh-agent" "$bash_config" 2>/dev/null; then
  echo "Adding SSH agent to $bash_config..."
  {
    echo "# SSH agent setup"
    echo "if [ -z \"\$SSH_AUTH_SOCK\" ]; then"
    echo "    eval \$(ssh-agent -s) >/dev/null"
    echo "    ssh-add $ssh_key >/dev/null 2>&1"
    echo "fi"
  } >> "$bash_config"
else
  echo "SSH agent already configured in $bash_config."
fi

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add "$ssh_key" <<< "$passphrase"
if [ $? -ne 0 ]; then
  echo "Failed to add SSH key to agent."
  exit 1
fi

# Test SSH connection
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com
if [ $? -eq 255 ]; then
  echo "SSH connection failed. Ensure the key is added to GitHub."
else
  echo "SSH connection successful."
fi

# Recommend SSH key management for NixOS
echo ""
echo "For persistent SSH key management on NixOS, add to /etc/nixos/configuration.nix:"
echo "{"
echo "  programs.ssh.startAgent = true;"
echo "  environment.systemPackages = with pkgs; [ gnome.gnome-keyring ];"
echo "}"
echo "Then run 'sudo nixos-rebuild switch'."
echo "Use 'seahorse' for GUI key management if installed."

# Output next steps
echo ""
echo "Next steps:"
echo "1. Go to GitHub > Settings > SSH and GPG keys > New SSH key."
echo "2. Paste the copied key (run 'xclip -o' if needed)."
echo "3. Name it (e.g., 'NixOS Git') and save."
echo "4. Test lazygit: Run 'lazygit', stage (s), commit (c), push (p)."
echo "If issues persist, check 'git remote -v' and 'ssh -vT git@github.com'."
