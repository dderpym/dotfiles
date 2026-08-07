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
