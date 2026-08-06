{ pkgs, inputs, ... }:

{
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.stoler = { pkgs, ... }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.pi-agent.homeModules.default
      inputs.niri-flake.homeModules.config
      ./niri.nix
      ./noctalia.nix
    ];

    home.stateVersion = "25.11";

    home.packages = with pkgs; [
      # noctalia v5 — only packaged on nixpkgs unstable (see flake.nix); the
      # 26.05 `noctalia-shell` was the v4 quickshell line this replaces
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.noctalia

      # file browser
      nemo          # Mod+F bind

      # coding
      neovim
      lazydocker

      # chat
      vesktop
      slack

      # media & system keys (niri binds in niri.nix)
      playerctl     # media keys via MPRIS
      # pactl is in configuration.nix's systemPackages — the audio stack
      # (services.pipewire) is system-managed, so its client CLI lives there too.
      brightnessctl # brightness keys (uses systemd-logind API, no udev rules)

      # screenshot pipeline (niri-shot itself is defined in niri-shot.nix)
      grim
      slurp
      wl-clipboard  # wl-copy: screenshots to clipboard
      wayfreeze     # freeze the screen while selecting a region
      jq            # parse niri msg output (also used by Mod+Shift+Q)
      libnotify     # notify-send: screenshot feedback

      # declarative screenshot helper (region/full -> clip/file)
      (import ./niri-shot.nix { inherit pkgs; })
    ];

    # idle/suspend is owned by noctalia (see idle.* in noctalia.nix)

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

