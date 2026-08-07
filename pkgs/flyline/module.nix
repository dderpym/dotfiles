# Home-manager module for flyline.
#
# Bespoke until flyline lands in nixpkgs — upstream ships a *NixOS* module
# (`nixosModules.flyline`) that uses `environment.systemPackages`, which is no
# use for a per-user home-manager setup.
#
# The package is pulled from the parent flake's `flyline` input, which this
# repo passes to home-manager modules via `extraSpecialArgs` (see flake.nix).
#
# ORDERING (why initExtra + mkAfter, not bashrcExtra):
#   home-manager's bash template emits `bashrcExtra` at the TOP of .bashrc and
#   `initExtra` at the BOTTOM, after the interactive-shell guard. kitty's shell
#   integration is `initExtra` at default priority, so loading flyline via
#   `initExtra` + `mkAfter` guarantees it runs *after* kitty — which flyline
#   needs to exit cleanly (commit b5301d7). `bashrcExtra` would put flyline
#   before kitty again, reintroducing the bug.
{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.programs.flyline;

  # Package from the flake input (nixpkgs follows'd to 26.05 by the parent).
  flylinePkg = inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.programs.flyline = {
    enable = mkEnableOption "flyline, a modern command-line replacement for Bash";

    package = mkOption {
      type = types.package;
      default = flylinePkg;
      defaultText = "inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default";
      description = ''
        The flyline package to use. Defaults to the package from the flake's
        `flyline` input; override this once flyline is packaged in nixpkgs
        (e.g. `pkgs.flyline`).
      '';
    };

    enableBashIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to load the flyline loadable builtin at the very end of
        `.bashrc`, after all other shell integration (notably kitty's).
      '';
    };

    agentModeCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        A bash command to run right after flyline is enabled, to configure
        agent mode (e.g. a `flyline set-agent-mode ...` invocation).

        Flyline settings live in the builtin's memory only — nothing is
        persisted to disk — so any `flyline ...` configuration must be re-run
        at every shell startup (the README's "copy into your .bashrc").
        Defining it here instead of a separate `initExtra` guarantees it runs
        after the `enable -f` line above.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash.initExtra = mkIf cfg.enableBashIntegration (mkAfter ''
      if [[ $- == *i* ]]; then
        if enable -f "${cfg.package}/lib/libflyline.so" flyline >/dev/null 2>&1; then
          ${optionalString (cfg.agentModeCommand != null) cfg.agentModeCommand}
        fi
      fi
    '');
  };
}
