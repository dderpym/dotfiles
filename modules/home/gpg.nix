{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry = {
      # pinentry-all defaults to GTK2, which our Catppuccin theme does not cover.
      package = pkgs.pinentry-qt;
    };
    enableSshSupport = true;
    enableExtraSocket = true;
  };
}
