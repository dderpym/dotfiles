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
}
