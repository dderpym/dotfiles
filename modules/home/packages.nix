{ pkgs, inputs, unstable, ... }:

{
  programs.btop.enable = true;

  home.packages = with pkgs; [
    unstable.noctalia
    pkgs.wl-clipboard
    (import ../../pkgs/niri-shot.nix { inherit pkgs; })
    xwayland-satellite

    # flake-only package (not in nixpkgs); keep its own nixpkgs, see flake.nix
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

    # File manager. Extensions are the Mint default set (emblems, fileroller,
    # python, folder-color-switcher); the last one pairs with the
    # catppuccin-papirus-folders package below for per-folder colours.
    nemo-with-extensions
    zathura
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "blue"; })

    gnumake
    lazydocker

    vesktop
    slack
    prismlauncher
    lutris

    wineWow64Packages.stable
    winetricks

    playerctl
    brightnessctl
    pavucontrol

    evtest

    python3
    unzip
    wget
    curl
    gnutar

    udiskie
  ];
}
