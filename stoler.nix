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
        enableBashIntegration = true; # Automatically injects Kitty's integration script into Bash
        mode = "enabled";            # Keeps default features: no-cursor, title, completion, prompt-mark
      };
      settings = {
        # Allows Kitty to recognize shell processes without popping confirmation modals
        confirm_os_window_close = -1; # Close window if the shell has no running child tasks
      };
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        FLYLINE_SO="${inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/libflyline.so"
        if [[ -f "$FLYLINE_SO" ]]; then
          enable -f "$FLYLINE_SO" flyline >/dev/null 2>&1
        fi
      '';
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

