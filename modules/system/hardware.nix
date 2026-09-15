{ ... }:

{
  # zstd compression on every btrfs filesystem. The root subvols @ and @nix
  # are declared in the generated hardware-configuration.nix ("do not
  # modify"), so their mount options are merged in here instead — survives
  # nixos-generate-config. `compress` (not compress-force) lets btrfs skip
  # incompressible data; level defaults to 3. Affects new writes only;
  # existing data was compressed once via
  # `btrfs filesystem defragment -r -czstd <mountpoint>`.
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" ];

  # 568G btrfs data partition (nvme0n1p8), mounted as /media
  fileSystems."/media" =
    { device = "/dev/disk/by-uuid/e31be7e9-2362-4a4d-8da6-036e16314cee";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
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

  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
