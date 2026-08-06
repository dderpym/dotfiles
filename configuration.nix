{ config, lib, pkgs, inputs, ... }:

{
  # HARDWARE SETUP
  imports = [
    ./hardware-configuration.nix
    ./stoler.nix
    inputs.nix-index-database.nixosModules.nix-index
  ];

  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.upower.enable = true;

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
  services.desktopManager.plasma6.enable = true;
  programs.niri.enable = true;

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
  ];

  programs.nix-index-database.comma.enable = true;

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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11"; # Did you read the comment?
}

