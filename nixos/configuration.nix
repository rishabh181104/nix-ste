# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
# let
# sources = import ./nix/sources.nix;
# lanzaboote = import sources.lanzaboote;
# in
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "nix-ste";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
# networking.wireless.enable = true;

# Set your time zone.
  time.timeZone = "Asia/Kolkata";
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ste = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
      fish
        tree
      ];
  };

# Shell configuration
  environment.shells = with pkgs; [ bash zsh fish ];
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

# For Automounting usb's etc.
  services.udisks2.enable = true;
  services.udev.extraRules = ''
# Example: Mount USB drives to /media/<label> automatically
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media/%E{ID_FS_LABEL}"
    '';
  security.polkit.enable = true;

# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 8;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 8";
  };

# For Secure Boot On
  boot.bootspec.extensions = {
    "org.secureboot.osRelease" = config.environment.etc."os-release".source;
  };

# To allow unfree for google-chrome 
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  services.udev.packages = with pkgs; [ libmtp ];

# Setup for Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

# Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xrandr --output eDP-1 --mode "1920x1080" --rate "60.01"
      xrandr --output eDP-2 --mode "1920x1080" --rate "60.01"
      xrandr --output eDP-3 --mode "1920x1080" --rate "60.01"
      xrandr --output eDP-4 --mode "1920x1080" --rate "60.01"
      xrandr --output HDMI-1 --mode "1920x1080" --rate "60.01"
      xrandr --output HDMI-2 --mode "1920x1080" --rate "60.01"
      xrandr --output HDMI-3 --mode "1920x1080" --rate "60.01"
      xrandr --output HDMI-4 --mode "1920x1080" --rate "60.01"
      xwallpaper --zoom ~/Wallpapers/Pictures/Concept-Japanese\ house.png
      xset r rate 200 35 &
      '';
  };

# Explicitly enable or disable open-source kernel modules
  hardware.nvidia = {
# open = true; # Use open-source kernel modules (recommended for RTX/GTX 16xx GPUs)
    open = false; # Use proprietary kernel modules (uncomment if needed for older GPUs)
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.picom.enable = true;

# Configure keymap in X11
# services.xserver.xkb.layout = "us";
# services.xserver.xkb.options = "eurosign:e,caps:escape";

# Enable CUPS to print documents.
# services.printing.enable = true;

# Enable sound.
# services.pulseaudio.enable = true;
# OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

# Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

# Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.firefox.enable = true;

# List packages installed in system profile.
# You can use https://search.nixos.org/ to find more packages (and options).
  programs.ssh.startAgent = true;
  environment.systemPackages = with pkgs; [
##
## Packages for Hyprland
##
    hyprland
      hypridle
      hyprland-qt-support
      hyprland-qtutils
      hyprlock
      hyprpicker
      pyprland
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
      waybar
      wlogout
      wlroots_0_19
      swww
      rose-pine-hyprcursor
      libsForQt5.xwaylandvideobridge
      xwayland-run
      mako
      pavucontrol
      flat-remix-gtk
      papirus-icon-theme
      jamesdsp
      qt6.qtbase
      qt6.qtsvg
      qt6.qtvirtualkeyboard
      qt6.qtmultimedia
      imagemagick
      nwg-look

##
## Packages for Browsers
##
      google-chrome
      inputs.zen-browser.packages.${pkgs.system}.default

##
## Packages for Kernel and Signing Kernel
##
      sbctl
      niv
      mokutil
      openssl
      linuxHeaders
      mkinitcpio-nfs-utils
      linuxKernel.kernels.linux_zen
      efibootmgr

##
## Packages for daily-use as in office use
##
      stirling-pdf
      thunderbird
      libreoffice-fresh
      ntfs3g
      exfat
      exfatprogs
      gvfs
      mtpfs
      libmtp

##
## Social Media or Chatting apps
##
      whatsie
      discord

##
## Packages for Bluetooth
##
      blueman
      bluez
      bluez-tools

##
## Packages for Shell
##
      fish
      starship

##
## Packages for Nework
##
      networkmanager
      networkmanagerapplet

##
## Packages for Screenshot
##
      grim
      grimblast
      slurp
##
## Packages for Editors
##
      code-cursor
      vim 
      neovim
      wget
      fzf
      gnumake
      unzip
      shellcheck

##
## Packages for Terminals and some daily use terminal based packages
##
      alacritty
      foot
      kitty
      btop
      bat
      bc
      brightnessctl
      ripgrep
      keychain
      wl-clipboard
      xclip
      gnome-keyring
      fastfetch
      lazygit
      git
      psmisc

##
## Packages for Xorg/qtile
##
      python313Packages.qtile-extras
      xwallpaper
      pcmanfm
      xfce.thunar
      vlc
      mupdf
      rofi-wayland

##
## Packages like programming languages and packages for development
##
      python3Full
      nodejs_24
      go
      pipx
      python313Packages.pip
      python313Packages.virtualenv
      typescript-language-server
      vscode-langservers-extracted
      pyright
      sqls
      prettier
      lua-language-server
      stylua
      llvmPackages_20.libcxxClang
      astyle
      jdt-language-server
      python313Packages.debugpy
      vimPlugins.vim-ipython
      rPackages.autoimport
      python313Packages.black
      postgresql
      gdb
      shfmt
      cargo
      rustc
      rust-analyzer
      rustfmt

##
## Packages for Nvidia
##
      vulkan-loader
      vulkan-tools
      ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
      font-awesome
      nerd-fonts.dejavu-sans-mono
  ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:


# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

}

