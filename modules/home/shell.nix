{ pkgs, inputs, ... }:

{
  programs.bash = {
    enable = true;
    initExtra = ''
      enable -f "${inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/libflyline.so" flyline >/dev/null 2>&1
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_status$character";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
      };
    };
  };

  programs.lazygit.enable = true;
}
