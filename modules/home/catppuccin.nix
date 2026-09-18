{ ... }:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # autoEnable turns on catppuccin.gtk.icon, which sets gtk.iconTheme to
  # Papirus-Dark (backed by catppuccin-papirus-folders). Enabling home-manager's
  # gtk module is what actually emits ~/.config/gtk-3.0/settings.ini, so GTK apps
  # — nemo above all — pick the icons up. Before, only cosmic-files got the theme
  # (via its own config file); nemo is GTK, so it needs this.
  gtk.enable = true;

  catppuccin.cursors = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
}
