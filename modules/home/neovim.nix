{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withRuby = true;
    # Plugin builds, search, formatting and image rendering need these on PATH.
    # Language-specific SDKs and PlatformIO remain project/dev-shell concerns.
    extraPackages = with pkgs; [
      clang-tools
      deno
      fd
      gcc
      imagemagick
      nodejs_24
      python3
      ripgrep
      tree-sitter
      unzip
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua" = {
      source = ./nvim/lua;
      recursive = true;
    };
    "nvim/.neoconf.json".source = ./nvim/.neoconf.json;
    "nvim/stylua.toml".source = ./nvim/stylua.toml;
  };

  # Lazy/LazyVim rewrite these files. Seed a fresh laptop without replacing
  # local plugin updates or extras selections on subsequent switches.
  home.activation.neovimState = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/nvim"}
    for file in lazy-lock.json lazyvim.json; do
      target=${lib.escapeShellArg "${config.xdg.configHome}/nvim"}/"$file"
      if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        run ${pkgs.coreutils}/bin/install -m600 ${./nvim}/"$file" "$target"
      fi
    done
  '';
}
