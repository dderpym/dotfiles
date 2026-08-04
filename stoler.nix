{ pkgs, ... }:

{
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.stoler = { pkgs, ... }: {
    home.stateVersion = "24.11"; # Match your system's NixOS release version

    home.packages = with pkgs; [
      # productivity
      kitty
      neovim
      lazygit
      lazydocker

      # chat
      vesktop
      slack
    ];

    # Allows Home Manager to manage itself
    programs.home-manager.enable = true;
  };
}

