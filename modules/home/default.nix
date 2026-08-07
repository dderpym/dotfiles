{ inputs, ... }:

{
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "input" ];
  };

  home-manager.users.stoler = { pkgs, lib, inputs, unstable, ... }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.niri-flake.homeModules.config
      inputs.flyline-hm.homeManagerModules.flyline
      ./catppuccin.nix
      ./packages.nix
      ./gpg.nix
      ./shell.nix
      ./starship.nix
      ./kitty.nix
      ./niri.nix
      ./noctalia.nix
      ./mimeapps.nix
      ./pi.nix
    ];

    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
  };
}
