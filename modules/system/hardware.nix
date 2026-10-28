{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;

  services.fprintd.enable = true;
  # Noctalia drives fprintd directly for lockscreen fingerprint auth; keep its
  # password PAM path from trying to claim the same reader first.
  security.pam.services.login.fprintAuth = false;
  security.pam.services.sudo.rules.auth.fprintd.settings.timeout = 10;

  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Use a service rather than running the D-Bus client inside udev.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", ENV{POWER_SUPPLY_ONLINE}=="[01]", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart power-profile-auto.service"
  '';
  systemd.services.power-profile-auto = {
    description = "Select power profile for the current power source";
    # The daemon starts after multi-user.target; avoid ordering this before it.
    wantedBy = [ "graphical.target" ];
    requires = [ "power-profiles-daemon.service" ];
    after = [ "power-profiles-daemon.service" ];
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig.Type = "oneshot";
    script = ''
      profile=power-saver
      for online in /sys/class/power_supply/*/online; do
        if [[ -r "$online" && "$(< "$online")" == 1 ]]; then
          profile=performance
          break
        fi
      done
      ${config.services.power-profiles-daemon.package}/bin/powerprofilesctl set "$profile"
    '';
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    # Also sleep with a dock/external monitor; logind otherwise ignores the lid.
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HandlePowerKey = "poweroff";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/mnt/media" ];
  };

  # Priority 5 (default) outranks the btrfs swapfile (-2), so compressed RAM
  # fills first and the disk swapfile is only the overflow.
  zramSwap.enable = true;

  # Hibernate into the btrfs swapfile. resume_offset comes from
  # `btrfs inspect-internal map-swapfile -r /swap/swapfile` and must be
  # updated whenever the swapfile is recreated (e.g. a size change).
  boot.resumeDevice = "/dev/disk/by-uuid/89f724c8-a030-4e95-97c6-9ce1140a977b";
  boot.kernelParams = [ "resume_offset=6386453" ];

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
}
