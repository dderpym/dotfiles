{ inputs, pkgs, ... }:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # Catppuccin SDDM theme — flavor/accent match the home-manager catppuccin
  # module (modules/home/catppuccin.nix) so the login screen matches the session.
  catppuccin = {
    enable = true;
    # Opt into specific ports only (sddm below) — don't auto-enroll everything
    autoEnable = false;
    flavor = "mocha";
    accent = "blue";
    sddm.enable = true;
  };

  programs.niri.enable = true;
  # Plasma as a fallback session: niri is niche, so keep a known-good DE
  # selectable from SDDM in case the compositor breaks.
  services.desktopManager.plasma6.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # Works smoothly for Niri's screencast portal implementation
      xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = [ "gnome" "gtk" ];
        # File dialogs → gtk. nemo is a file *manager*, not a portal backend
        # (linuxmint/nemo has no FileChooser implementation), so the dialog is
        # GTK's — which shares ~/.config/gtk-3.0/bookmarks with nemo. Keep
        # gnome for ScreenCast/Screenshot (niri implements that backend
        # natively).
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };
}
