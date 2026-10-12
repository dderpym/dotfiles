{ ... }:

{
  # Default applications for the freedesktop MIME system.
  # Generates ~/.config/mimeapps.list (replaces the stale file left over
  # from the previous machine: remmina, libreoffice, lunarclient, etc.).
  xdg.mimeApps.enable = true;

  xdg.mimeApps.defaultApplications = {
    # Directories → nemo
    "inode/directory" = [ "nemo.desktop" ];
    "application/x-gnome-saved-search" = [ "nemo.desktop" ];

    # Text & source files → neovim. nvim.desktop ships with the neovim
    # package (Terminal=true), so files open in kitty + nvim.
    "text/plain" = [ "nvim.desktop" ];
    "text/english" = [ "nvim.desktop" ];
    "text/markdown" = [ "nvim.desktop" ];
    "text/csv" = [ "nvim.desktop" ];
    "text/xml" = [ "nvim.desktop" ];
    "text/x-c" = [ "nvim.desktop" ];
    "text/x-c++" = [ "nvim.desktop" ];
    "text/x-c++hdr" = [ "nvim.desktop" ];
    "text/x-c++src" = [ "nvim.desktop" ];
    "text/x-chdr" = [ "nvim.desktop" ];
    "text/x-csrc" = [ "nvim.desktop" ];
    "text/x-java" = [ "nvim.desktop" ];
    "text/x-python" = [ "nvim.desktop" ];
    "text/x-ruby" = [ "nvim.desktop" ];
    "text/x-perl" = [ "nvim.desktop" ];
    "text/x-php" = [ "nvim.desktop" ];
    "text/x-tcl" = [ "nvim.desktop" ];
    "text/x-tex" = [ "nvim.desktop" ];
    "text/x-makefile" = [ "nvim.desktop" ];
    "text/x-moc" = [ "nvim.desktop" ];
    "text/x-pascal" = [ "nvim.desktop" ];
    "text/x-shellscript" = [ "nvim.desktop" ];
    "application/json" = [ "nvim.desktop" ];
    "application/xml" = [ "nvim.desktop" ];
    "application/x-shellscript" = [ "nvim.desktop" ];
    "application/x-yaml" = [ "nvim.desktop" ];

    # Documents → zathura (lightweight, vim-style keys; the mupdf backend
    # also handles epub).
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];

    # Web → firefox
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];

    # Chat protocol handlers (registered by the apps themselves)
    "x-scheme-handler/discord" = [ "vesktop.desktop" ];
    "x-scheme-handler/slack" = [ "slack.desktop" ];
  };
}
