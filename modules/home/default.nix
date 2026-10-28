{ inputs, ... }:

{ # Preserve unmanaged files during migration; existing backups are not overwritten.
  home-manager.backupFileExtension = "before-home-manager";

  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "input" "libvirtd" "gamemode" ];
  };

  home-manager.users.stoler = { pkgs, lib, inputs, unstable, ... }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.niri-flake.homeModules.config
      inputs.flyline-hm.homeManagerModules.flyline
      ./catppuccin.nix
      ./packages.nix
      ./gpg.nix
      ./git.nix
      ./ssh.nix
      ./neovim.nix
      ./shell.nix
      ./starship.nix
      ./kitty.nix
      ./niri.nix
      ./noctalia.nix
      ./wluma.nix
      ./mimeapps.nix
      ./nemo.nix
      ./pi.nix
      ./claude.nix
    ];

    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
  };
}
