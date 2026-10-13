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

  # Keep other Qt apps on upstream Catppuccin; pinentry gets roomier flat controls.
  catppuccin.kvantum.apply = false;
  qt = {
    enable = true;
    style = {
      name = "kvantum";
      # Pinentry uses Qt6; avoid pulling in a second, Qt5 theme stack.
      package = pkgs.qt6Packages.qtstyleplugin-kvantum;
    };
    kvantum = {
      enable = true;
      settings = {
        General.theme = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}";
        Applications.Pinentry = [ "pinentry" "pinentry-qt" ];
      };
    };
  };

  xdg.configFile."Kvantum/Pinentry/Pinentry.kvconfig".source = ../../assets/pinentry/Pinentry.kvconfig;
  xdg.configFile."Kvantum/Pinentry/Pinentry.svg".source = ../../assets/pinentry/Pinentry.svg;

  catppuccin.cursors = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
}
