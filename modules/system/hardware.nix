{ ... }:

{
  hardware.bluetooth.enable = true;

  services.fprintd.enable = true;
  # Noctalia drives fprintd directly for lockscreen fingerprint auth; keep its
  # password PAM path from trying to claim the same reader first.
  security.pam.services.login.fprintAuth = false;

  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.tlp = {
    enable = true;
    # Preserve Noctalia's profile controls without running a competing daemon.
    pd.enable = true;
    # Avoid peripherals failing to wake; retain TLP's other power-saving defaults.
    settings.USB_AUTOSUSPEND = 0;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKey = "poweroff";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
