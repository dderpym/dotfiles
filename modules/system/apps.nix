{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.default
  ];

  # FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # CONTAINERS
  virtualisation.docker.enable = true;

  # NIX COMPATIBILITY LAYERS
  services.envfs.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core System & Basics
      stdenv.cc.cc
      zlib
      glibc
      util-linux
      
      # Web & Crypto
      openssl
      curl
      libkrb5
      
      # Common UI/App Runtimes (.NET, Electron, Node, Python)
      icu
      glib
      dbus
      atk
      pango
      cairo
      gdk-pixbuf
      gtk3
      libdrm
      mesa
      alsa-lib
      nspr
      nss
      libsecret
      systemd
      
      # Graphics, Fonts & Window Managers (X11 / Wayland)
      fontconfig
      freetype
      libGL
      vulkan-loader
      wayland
      libxkbcommon
      libice
      libsm
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxscrnsaver
      libvlc
    ];
  };

  # PROGRAMS
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  services.openssh.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Optional: open ports for Remote Play
    dedicatedServer.openFirewall = true; # Optional: open ports for dedicated servers
  };

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lm_sensors
    efibootmgr
    git
    nano
    curl
    wget
    # pactl — volume/mute keys (client for the system-managed pipewire-pulse)
    pulseaudio
  ];

  programs.nix-index-database.comma.enable = true;
}
