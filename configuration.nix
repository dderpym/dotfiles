{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/hardware.nix
    ./modules/system/boot.nix
    ./modules/system/nix.nix
    ./modules/system/networking.nix
    ./modules/system/display.nix
    ./modules/system/locale.nix
    ./modules/system/apps.nix
    ./modules/system/virtualisation.nix
    ./modules/home/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # First NixOS version installed on this machine. Do NOT change this after
  # the initial install, even when upgrading NixOS releases — see
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
