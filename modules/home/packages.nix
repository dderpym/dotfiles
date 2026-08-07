{ pkgs, inputs, unstable, ... }:

{
  home.packages = with pkgs; [
    unstable.noctalia
    xwayland-satellite

    # flake-only package (not in nixpkgs); keep its own nixpkgs, see flake.nix
    inputs.nix-alien.packages.${pkgs.system}.nix-alien

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
