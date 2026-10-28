{ lib, pkgs, ... }:

{
  boot.supportedFilesystems = [ "ntfs" ];

  # Panther Lake benefits from newer hardware support; follow stable, not LTS.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Lanzaboote replaces systemd-boot: it signs the kernel, initrd and boot
  # loader with the db key and installs UKIs + its own systemd-boot loader
  # entries. systemd-boot must stay disabled (docs force it off).
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  # Boot straight into the default entry; hold a key (space) at boot to open the
  # menu for older generations.
  boot.loader.timeout = 0;

  # systemd 260 PID 1 probes the console size with ANSI queries at startup, in
  # the initrd and again after switch-root. The Linux VT never answers
  # "CSI 18 t", so each probe idles for its full 333ms timeout (~0.67s per
  # boot, no CPU or IO). Giving the size on the cmdline makes
  # reset_dev_console_fd() skip the probe. Values are this laptop's fbcon grid
  # (kernel logs "frame buffer device 180x60", same under simpledrm and xe).
  # Drop once systemd skips the query on a VT (systemd/systemd#44473).
  boot.kernelParams = [
    "systemd.tty.rows.console=60"
    "systemd.tty.columns.console=180"
  ];
}
