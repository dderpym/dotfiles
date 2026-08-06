{
  description = "Minimal wrapper for Pi agent with runtime dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, llm-agents }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          piPkg = llm-agents.packages.${system}.pi;
          # rtkPkg = llm-agents.packages.${system}.rtk;
          agentBrowserPkg = llm-agents.packages.${system}.agent-browser;

          pi-wrapped = pkgs.writeShellApplication {
            name = "pi";
            runtimeInputs = with pkgs; [
              piPkg
              # rtkPkg
              agentBrowserPkg
              bun
              nodejs_24
              uv
              chromium
              playwright-driver.browsers
            ];
            text = ''
              export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
              export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"

              exec ${piPkg}/bin/pi "$@"
            '';
          };
        in
        {
          default = pi-wrapped;
          pi = pi-wrapped;
        }
      );

      homeModules.default = { config, pkgs, ... }: {
        home.packages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
