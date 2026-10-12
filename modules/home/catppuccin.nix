{ config, pkgs, ... }:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # The Catppuccin module themes GTK icons only; Nemo also needs a GTK theme.
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = config.catppuccin.flavor;
        accents = [ config.catppuccin.accent ];
      };
    };
  };

  catppuccin.cursors = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
}
