{ pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    unstable.noctalia
    xwayland-satellite

    cosmic-files
    cosmic-settings
    zathura
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "blue"; })

    neovim
    lazydocker

    vesktop
    slack

    playerctl
    brightnessctl
    pavucontrol

    btop
    evtest
  ];
}
