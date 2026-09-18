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

    # Secure Boot via signed UKIs. No per-release branches — pin the stable
    # release tag. nixpkgs follows so lzbt/stub build against our nixos-26.05
    # instead of dragging in their own nixpkgs.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flyline = {
      url = "github:HalFrgrd/flyline";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bespoke home-manager module for flyline (upstream only ships a NixOS
    # module). Path subflake so its inputs lock into this flake; its `flyline`
    # input follows ours, so the package is built with the same nixpkgs and
    # flake.lock keeps a single flyline node instead of a `flyline_2`.
    flyline-hm = {
      url = "path:./pkgs/flyline";
      inputs.flyline.follows = "flyline";
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

    # nix-alien runs unpatched binaries inside a FHS env. It must keep its own
    # nixpkgs + nix-index-database: the package embeds its locked nixpkgs rev
    # into the generated FHS env and pairs it with the nix-index-database db
    # that nix-locate queries. Upstream explicitly says overriding these inputs
    # is unsupported ("may cause mismatches... causing possibly incorrect
    # results"), so do NOT add follows here.
    nix-alien.url = "github:thiagokokada/nix-alien";

    # llm-agents provides the pi package (and agent-browser). It keeps its own
    # nixpkgs (unstable) on purpose: numtide's binary cache
    # (cache.numtide.com) builds against it, so pi/rtk/agent-browser hit the
    # cache instead of compiling from source. Do NOT add a follows here.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Agent skills for pi (Agent Skills standard). Pinned as inputs so `nix
    # flake update` bumps them like any other dependency; pi discovers the
    # pinned dirs from ~/.pi/agent/skills/ (see modules/home/pi.nix).
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    ponytail = {
      url = "github:dietrichgebert/ponytail";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }@inputs:
    let
      system = "x86_64-linux";
      # packages that only exist on unstable (noctalia); see input comment above
      unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        stoletop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs unstable; };
          modules = [
            ./configuration.nix

            lanzaboote.nixosModules.lanzaboote

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # let home-manager modules (noctalia.nix) see flake inputs
              home-manager.extraSpecialArgs = { inherit inputs unstable; };
            }
          ];
        };
      };
    };
}
