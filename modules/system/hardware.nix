{ config, unstable, ... }:

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

  services.tlp = {
    enable = true;
    # TLP 1.10 adds configurable automatic AC/battery profile selection.
    package = unstable.tlp.override { enableRDW = config.networking.networkmanager.enable; };
    # Preserve Noctalia's profile controls without running a competing daemon.
    pd.enable = true;
    pd.package = unstable.tlp-pd;
    settings = {
      TLP_AUTO_SWITCH = 1;
      TLP_PROFILE_AC = "PRF";
      TLP_PROFILE_BAT = "SAV";
      # Avoid peripherals failing to wake; retain TLP's other power-saving defaults.
      USB_AUTOSUSPEND = 0;
    };
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    # Also sleep with a dock/external monitor; logind otherwise ignores the lid.
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "poweroff";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
