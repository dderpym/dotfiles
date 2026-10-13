{ ... }:

{
  networking.hostName = "stoletop";
  networking.networkmanager.enable = true;
  # Nothing here needs boot to block until Wi-Fi/VPN are online.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.tailscale.enable = true;
  # Enable Tailscale routing features (server, client, or both)
  services.tailscale.useRoutingFeatures = "both";
}
