{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      # hacky workaround to get starship to init before kitty
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };

  programs.flyline = {
    enable = true;
    agentModeCommand = ''
      flyline set-agent-mode \
        --system-prompt "Be concise. Answer with a JSON array of at most 3 items with objects containing: command and description. Command will be a Bash command." \
        --trigger-prefix ': ' \
        --command 'pi -p --no-session'
    '';
  };

  # full prompt config lives in starship.nix; this module only owns the
  # bash-init ordering hack and the package
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
  };

  programs.lazygit.enable = true;
}
