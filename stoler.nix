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
      # locks
      hyprlock
      wlogout

      noctalia-shell

      # coding
      neovim
      lazydocker

      # chat
      vesktop
      slack
    ];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "niri msg action power-on-monitors";
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
          {
            timeout = 1200;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

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

