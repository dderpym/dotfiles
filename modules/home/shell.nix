{
  programs.bash = {
    enable = true;
  };

  # flyline is enabled via the bespoke home-manager module (imported in
  # default.nix); it loads the loadable builtin at the very end of .bashrc,
  # after kitty's shell integration.
  programs.flyline.enable = true;

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
