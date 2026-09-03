{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/hardware.nix
    ./modules/system/boot.nix
    ./modules/system/nix.nix
    ./modules/system/networking.nix
    ./modules/system/display.nix
    ./modules/system/drkonqi.nix # masks drkonqi-coredump-launcher crash loop; delete once drkonqi ≥ 6.7.2
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
