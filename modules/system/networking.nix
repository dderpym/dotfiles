{ ... }:

{
  networking.hostName = "stoletop";
  networking.networkmanager.enable = true;
  # Nothing here needs boot to block until Wi-Fi/VPN are online.
  systemd.services.NetworkManager-wait-online.enable = false;
  # Upstream is Type=dbus: the start job only ends once NM owns its bus name
  # (~1.1s here), and NM is ordered Before=network.target, which
  # systemd-user-sessions waits on, so the login screen sat behind NM init.
  # "exec" ends the job at exec; D-Bus clients queue until the name appears.
  systemd.services.NetworkManager.serviceConfig.Type = "exec";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  networking.firewall = {
    enable = true;
    # Fixes the UDP packet drops when using direct-connection exit nodes
    checkReversePath = "loose";
  };

}
