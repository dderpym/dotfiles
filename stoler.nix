{ pkgs, ... };

{
  # USER ACCOUNT
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    packages = with pkgs; [
      # productivity
      kitty
      neovim
      lazygit
      lazydocker

      # chat
      vesktop
    ];
  };
}
