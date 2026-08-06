{
  description = "stoletop - a modular nixos flake config";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://catppuccin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-cosmic = {
      url = "github:catppuccin/cosmic-desktop";
      flake = false;
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flyline = {
      url = "github:HalFrgrd/flyline";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia v5 is packaged only on nixpkgs unstable (the 26.05 `noctalia-shell`
    # package is the old v4 quickshell line). Pinning unstable as a separate
    # input keeps the rest of the system on 26.05 and gets the prebuilt
    # `noctalia` from cache.nixos.org — the default binary cache — so no
    # cachix setup is needed. (Following the noctalia flake input instead would
    # drag in its channel-tarball nixpkgs and defeat its cachix cache.)
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    # Agent skills for pi (Agent Skills standard). Pinned as inputs so `nix
    # flake update` bumps them like any other dependency; pi discovers the
    # pinned dirs from ~/.pi/agent/skills/ (see pi.nix).
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    ponytail = {
      url = "github:dietrichgebert/ponytail";
      flake = false;
    };

    pi-agent = {
      url = "path:./pkgs/pi/";
      inputs.nixpkgs.follows = "nixpkgs";
      # llm-agents stays on its own nixpkgs (unstable) so numtide's
      # binary cache (cache.numtide.com) hits for pi/rtk/agent-browser.
      inputs.llm-agents.follows = "llm-agents";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      stoletop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; 
        modules = [
          ./configuration.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # let home-manager modules (noctalia.nix) see flake inputs
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}

