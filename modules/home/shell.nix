{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      # hacky workaround to get starship to init before kitty
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };

  programs.flyline.enable = true;

  # full prompt config lives in starship.nix; this module only owns the
  # bash-init ordering hack and the package
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
  };

  programs.lazygit.enable = true;
}
