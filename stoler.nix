{ pkgs, inputs, ... }:

{
  _module.args = { inherit inputs; };

  users.users.stoler = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.stoler = { pkgs, ... }: {
    home.stateVersion = "25.11"; # Match your system's NixOS release version

    home.packages = with pkgs; [
      # terminal
      kitty
      inputs.flyline.packages.${pkgs.system}.default

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

    programs.bash = {
      enable = true;
      initExtra = ''
        export GPG_TTY=$(tty)
        enable -f ${inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/libflyline.so flyline
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

