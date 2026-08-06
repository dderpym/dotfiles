{ ... }:

{
  networking.hostName = "stoletop";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  # Enable Tailscale routing features (server, client, or both)
  services.tailscale.useRoutingFeatures = "both";
}
