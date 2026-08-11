{ ... }:

{
  # 568G btrfs data partition (nvme0n1p8), mounted as /media
  fileSystems."/media" =
    { device = "/dev/disk/by-uuid/e31be7e9-2362-4a4d-8da6-036e16314cee";
      fsType = "btrfs";
    };

  hardware.bluetooth.enable = true;

  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKey = "poweroff";
  };
}
