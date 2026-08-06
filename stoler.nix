{ pkgs, inputs, lib, ... }:

{
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.stoler = { pkgs, lib, ... }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.pi-agent.homeModules.default
      inputs.niri-flake.homeModules.config
      ./niri.nix
      ./noctalia.nix
      ./mimeapps.nix
      ./pi.nix
    ];

    home.stateVersion = "25.11";

    home.packages = with pkgs; [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.noctalia

      cosmic-files
      cosmic-settings

      # default PDF/epub viewer (mimeapps.nix)
      zathura
      (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "blue"; })

      # coding
      neovim
      lazydocker

      # chat
      vesktop
      slack

      # media & system keys (niri binds in niri.nix)
      playerctl
      brightnessctl

      grim
      slurp
      wl-clipboard
      wayfreeze
      jq
      libnotify

      (import ./niri-shot.nix { inherit pkgs; })
    ];

    home.file.".config/cosmic/com.system76.CosmicTk/v1/icon_theme".text = ''
      "Papirus-Dark"
    '';

    home.activation.catppuccinCosmicTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.cosmic-settings}/bin/cosmic-settings appearance import \
        ${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-mocha-blue+round.ron
    '';

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "blue";
    };

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      pinentry = {
        package = pkgs.pinentry-all;
      };
      enableSshSupport = true;
      enableExtraSocket = true;
    };

    programs.kitty = {
      enable = true;
      shellIntegration = {
        enableBashIntegration = true;
        mode = "enabled";
      };
      settings = {
        confirm_os_window_close = -1;
      };
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        enable -f "${inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/libflyline.so" flyline >/dev/null 2>&1
      '';
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      
      settings = {
        add_newline = false;

        format = "$directory$git_branch$git_status$character";

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };

        directory = {
          style = "bold cyan";
          truncation_length = 3;
        };
      };
    };

    programs.lazygit.enable = true;

    programs.home-manager.enable = true;
  };
}

