# ==========================================
#           STECORE FISH SHELL
# ==========================================
# Fish shell configuration for stecore
# 
# Features:
# - Interactive startup with ASCII art and fastfetch
# - SSH agent integration
# - Starship prompt integration
# - Environment variables for Wayland/NVIDIA
# - Comprehensive aliases and functions
# - Package management shortcuts
# ==========================================

# ==========================================
#           INTERACTIVE STARTUP
# ==========================================
# Run ASCII art and system info on startup
if status is-interactive
  # Run ASCII art generation script and then fastfetch
  if test -f ~/.config/fish/scripts/generate_ascii.sh
    fish ~/.config/fish/scripts/generate_ascii.sh && fastfetch
  else
    echo "Warning: generate_ascii.sh not found, running fastfetch without custom ASCII art"
    fastfetch
  end
end

# ==========================================
#           SSH AGENT SETUP
# ==========================================
# Initialize SSH agent for key management
if status is-interactive
  eval (ssh-agent -c)
  ssh-add ~/.ssh/id_rsa.pub >/dev/null 2>&1
end

# ==========================================
#           PROMPT CONFIGURATION
# ==========================================
# Initialize starship prompt
starship init fish | source

# ==========================================
#           ENVIRONMENT VARIABLES
# ==========================================
# Wayland and NVIDIA configuration
set -Ux OZONE_PLATFORM wayland
set -Ux __GLX_VENDOR_LIBRARY_NAME nvidia
set -Ux MOZ_ENABLE_WAYLAND 1

# Editor and application preferences
set -gx EDITOR nvim
set -gx TERMINAL alacritty
set -gx BROWSER waterfox
set -gx VISUAL nvim

# Configuration file paths
set -gx FILE ~/.config/fish/config.fish
set -gx STARSHIP_CONFIG ~/.config/starship.toml

# SSH and locale settings
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# PATH configuration
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH /usr/local/bin $PATH
set -gx PATH /usr/bin $PATH
set -gx PATH $HOME/.cargo/env.fish $PATH

# ==========================================
#           NixOS ALIASES
# ==========================================
alias update="sudo nixos-rebuild switch --flake ~/nix-ste/nixos"
alias upgrade="nix flake update && sudo nixos-rebuild switch --upgrade --flake ~/nix-ste/nixos"

# ==========================================
#           BASIC ALIASES
# ==========================================
# File and directory operations
alias l='ls -CF'
alias clr='clear'
alias c='clear'
alias cls='clear'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias rmd='/bin/rm  --recursive --force --verbose '

# Navigation shortcuts
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'

# ==========================================
#           EDITOR ALIASES
# ==========================================
# Neovim and editor shortcuts
alias vim='nvim'
alias n='nvim'
alias sn='sudo nvim'
alias nv='nvim'
alias nvi='nvim'
alias v='nvim'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'

# ==========================================
#           SYSTEM ALIASES
# ==========================================
# System information and monitoring
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias h="history | grep "
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep "
alias checkcommand="type -t"
alias openports='netstat -nape --inet'

# System control
alias reboot='systemctl reboot'
alias logout='loginctl kill-session $XDG_SESSION_ID'
alias shutdown='sudo shutdown now'
alias restart-dm='sudo systemctl restart display-manager'

# ==========================================
#           FILE OPERATIONS
# ==========================================
# Advanced file operations
alias ls='ls -aFh --color=always'
alias la='ls -Alh'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lu='ls -lturh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh |more'
alias lw='ls -xAh'
alias ll='ls -Fls'
alias labc='ls -lap'
alias lf="ls -l | egrep -v '^d'"
alias ldir="ls -l | egrep '^d'"
alias lla='ls -Al'
alias las='ls -A'
alias lls='ls -l'

# Disk and space management
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
alias duf='duf -hide special'

# ==========================================
#           ARCHIVE OPERATIONS
# ==========================================
# Archive and compression
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# ==========================================
#           PERMISSIONS & SECURITY
# ==========================================
# File permissions
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Security and system
alias sha1='openssl sha1'
alias freshclam='sudo freshclam'

# ==========================================
#           DEVELOPMENT & TOOLS
# ==========================================
# Development tools
alias run='/usr/bin/python3'
alias grep='grep --color=auto'
alias bright='brightnessctl set'
alias tty_kill_all="sudo pkill -t $(who | awk '$2 != "tty1" {print $2}' | sort -u | paste -sd,)"

# Video conversion
alias convert='ffmpeg -i $argv[1] -filter_complex "[0:v] fps=10,scale=320:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" $argv[2]'

# System monitoring
alias fetch='fastfetch'
alias macchina='$HOME/.cargo/bin/./macchina'

# ==========================================
#           UTILITY ALIASES
# ==========================================
# Various utilities
alias multitail='multitail --no-repeat -c'
alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'
alias kssh="kitty +kitten ssh"
alias smv='sudo mv'
alias scp='sudo cp'
alias web='cd /var/www/html'
alias ebrc='edit ~/.bashrc'
alias hlp='less ~/.bashrc_help'
alias da='date "+%Y-%m-%d %A %T %Z"'

# Entertainment
alias anime='~/dotfiles/./ani-cli'

# ==========================================
#           FUNCTIONS
# ==========================================
# Fish greeting function
function fish_greeting
  echo "THIS IS FISH, BRUV!:)"
end

# Create directory and change to it
function mkcd
  mkdir -p $argv[1]; and cd $argv[1]
end

# Reload fish shell
function reload
  exec fish
end

# Fish prompt using starship
function fish_prompt
  starship prompt
end

# Brave browser with NVIDIA support
function brave-nvidia
  env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia brave-browser --use-gl=desktop
end

# Just for cd and ls -a in a single command
function cd
  builtin cd $argv[1]; and ls -a
end

# ==========================================
#           EXTERNAL CONFIGURATIONS
# ==========================================
# Source local fish configuration if it exists
if test -f ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

# ==========================================
#           WINE CONFIGURATION
# ==========================================
# Wine performance settings
export WINEESYNC=1
export WINEFSYNC=1

# ==========================================
#           OPAM CONFIGURATION
# ==========================================
# OCaml package manager configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '~/.opam/opam-init/init.fish' && source '~/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true

# ==========================================
#           AUTOMATIC SESSION START
# ==========================================
# Automatic Hyprland session start on tty1
if test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
  exec dbus-run-session hyprland
end

# Activate pywal16 environment
# source ~/pywal16-env/bin/activate.fish

# Generated for envman. Do not edit.
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
