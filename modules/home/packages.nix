{ pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    # noctalia v5 is packaged only on nixpkgs unstable — see the comment on
    # the nixpkgs-unstable input in flake.nix for why it stays separate.
    unstable.noctalia

    cosmic-files
    cosmic-settings

    # default PDF/epub viewer (mimeapps.nix)
    zathura
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "blue"; })

    # coding
    neovim
    lazydocker

    # chat
    vesktop
    slack

    # media & system keys (niri binds in niri.nix)
    playerctl
    brightnessctl

    grim
    slurp
    wl-clipboard
    wayfreeze
    jq
    libnotify

    (import ../../pkgs/niri-shot.nix { inherit pkgs; })
  ];
}
