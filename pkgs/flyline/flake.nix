# Bespoke home-manager module for flyline.
#
# The official flyline repo only ships a NixOS module; this subflake wraps the
# upstream package in a proper home-manager module (`programs.flyline`) until
# flyline becomes an official nixpkgs package.
{
  description = "Home-manager module for flyline (Bash line editor)";

  # Official flyline repo. The parent flake follows this to its own `flyline`
  # input, so the package is built against the same nixpkgs as the system and
  # flake.lock keeps a single flyline node.
  inputs.flyline.url = "github:HalFrgrd/flyline";

  outputs = { self, flyline, ... }: {
    # Re-export the upstream package so the input stays live and the package
    # can be built standalone: `nix build path:./pkgs/flyline#default`.
    inherit (flyline) packages;

    homeManagerModules.flyline = import ./module.nix;
    homeManagerModules.default = self.homeManagerModules.flyline;
  };
}
