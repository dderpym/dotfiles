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

  programs.starship = {
    enable = true;
    enableBashIntegration = false;
    settings = {
      add_newline = false;
    };
  };

  programs.lazygit.enable = true;
}
