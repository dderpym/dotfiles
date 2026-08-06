{ config, lib, pkgs, inputs, ... }:

{
  # HARDWARE SETUP
  imports = [
    ./hardware-configuration.nix
    ./stoler.nix
    inputs.nix-index-database.nixosModules.nix-index
    inputs.catppuccin.nixosModules.catppuccin
  ];

  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKey = "poweroff";
  };

  # BOOTLOADER SETUP
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.extraEntries = {
	"arch.conf" = ''
		title Arch Linux
		linux /vmlinuz-linux
		initrd /initramfs-linux.img
		options root=UUID=f856667a-cb82-4eef-91f7-8f2c2329440b rw
  	'';
  };

  # NIX SETUP
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Keep the store deduplicated (daily timer — no per-build overhead) and tidy
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  # Faster substitution from binary caches (default http-connections is 25;
  # note: parallel-downloads was renamed to http-connections in newer nix)
  nix.settings.http-connections = 50;

  # TIMEZONE and LOCALE
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # NETWORKING
  networking.hostName = "stoletop";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  # Enable Tailscale routing features (server, client, or both)
  services.tailscale.useRoutingFeatures = "both";

  # DISPLAY AND GUI
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # Catppuccin SDDM theme — flavor/accent match the home-manager catppuccin
  # module (stoler.nix) so the login screen matches the session.
  catppuccin = {
    enable = true;
    # Opt into specific ports only (sddm below) — don't auto-enroll everything
    autoEnable = false;
    flavor = "mocha";
    accent = "blue";
    sddm.enable = true;
  };
  programs.niri.enable = true;
  services.desktopManager.plasma6.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # Works smoothly for Niri's screencast portal implementation
      xdg-desktop-portal-gtk
      xdg-desktop-portal-cosmic # FileChooser portal backed by cosmic-files
    ];
    config = {
      niri = {
        default = [ "gnome" "gtk" ];
        # Route file pickers to cosmic-files; keep gnome for ScreenCast/
        # Screenshot (niri implements the GNOME backend natively)
        "org.freedesktop.impl.portal.FileChooser" = "cosmic";
      };
    };
  };

  # FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # CONTAINERS
  virtualisation.docker.enable = true;

  # PROGRAMS
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  services.openssh.enable = true;

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

  # First NixOS version installed on this machine. Do NOT change this after
  # the initial install, even when upgrading NixOS releases — see
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11"; # Did you read the comment?
}

