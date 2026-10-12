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

  # Reuse the Catppuccin module's Kvantum theme for Qt pinentry.
  qt = {
    enable = true;
    style = {
      name = "kvantum";
      # Pinentry uses Qt6; avoid pulling in a second, Qt5 theme stack.
      package = pkgs.qt6Packages.qtstyleplugin-kvantum;
    };
  };

  catppuccin.cursors = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
}
