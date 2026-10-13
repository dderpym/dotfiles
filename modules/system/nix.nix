{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Persist cache trust for daemon builds, without relying on flake-config acceptance.
  nix.settings.substituters = [ "https://catppuccin.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
  ];

  # Keep the store deduplicated (daily timer — no per-build overhead) and tidy
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  # Faster substitution from binary caches (default http-connections is 25;
  # note: parallel-downloads was renamed to http-connections in newer nix)
  nix.settings.http-connections = 50;
}
