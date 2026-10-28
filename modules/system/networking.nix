{ ... }:

{
  networking.hostName = "stoletop";
  networking.networkmanager.enable = true;
  # Nothing here needs boot to block until Wi-Fi/VPN are online.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  networking.firewall = {
    enable = true;
    # Fixes the UDP packet drops when using direct-connection exit nodes
    checkReversePath = "loose";
  };

}
