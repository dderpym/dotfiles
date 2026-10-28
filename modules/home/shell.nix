{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    shellAliases.ssh = "kitten ssh";
    initExtra = ''
      # hacky workaround to get starship to init before kitty
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };

  programs.flyline = {
    enable = true;
    agentModeCommand = ''
      flyline set-agent-mode \
        --system-prompt "Be concise. Answer with a JSON array of at most 3 items with objects containing: command and description. Command will be a Bash command. As you are on nix-os, you may prefix possibly uninstalled binaries with , to have nix automatically install it. The command should: " \
        --trigger-prefix ': ' \
        --command 'pi -p --no-session'
    '';
  };

  # Full prompt config lives in starship.nix; bash integration stays off here.
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
  };

  programs.lazygit.enable = true;

  # direnv with nix-direnv: `use nix` gets a persistent, cached dev shell
  # (reloads are near-instant after the first build) instead of re-evaluating
  # every time the directory changes.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
