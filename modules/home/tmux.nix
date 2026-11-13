{ ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    escapeTime = 0; # no Esc delay in neovim
    terminal = "tmux-256color";
    # kitty's graphics protocol (used by image.nvim) needs passthrough.
    extraConfig = ''
      set -g allow-passthrough on
      # Outer TERM is xterm-kitty; without this tmux drops to 256 colors.
      set -as terminal-overrides ",xterm-kitty:RGB"
    '';
  };
}
