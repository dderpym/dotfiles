{ pkgs, lib, inputs, ... }:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # COSMIC icon theme — Catppuccin Papirus folders already installed above;
  # this picks the Papirus-Dark icon set for cosmic-files.
  home.file.".config/cosmic/com.system76.CosmicTk/v1/icon_theme".text = ''
    "Papirus-Dark"
  '';

  home.activation.catppuccinCosmicTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.cosmic-settings}/bin/cosmic-settings appearance import \
      ${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-mocha-blue+round.ron
  '';
}
