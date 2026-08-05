{ pkgs, inputs, ... }:

{
  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.stoler = { pkgs, ... }: {
    home.stateVersion = "25.11"; # Match your system's NixOS release version

    home.packages = with pkgs; [
      # coding
      neovim
      lazygit
      lazydocker

      # chat
      vesktop
      slack
    ];

    # Enable GPG natively
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
        # Keeps spacing between commands, but won't force a line on shell startup
        add_newline = true;

        # Basic fast preset (you can customize modules here)
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
  };

    programs.lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          activeBorderColor = [ "#89b4fa" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
        };
      };
    };

    # Allows Home Manager to manage itself
    programs.home-manager.enable = true;
  };
}

