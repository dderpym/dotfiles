{ lib, ... }:

{
  # Lanzaboote replaces systemd-boot: it signs the kernel, initrd and boot
  # loader with the db key and installs UKIs + its own systemd-boot loader
  # entries. systemd-boot must stay disabled (docs force it off).
  boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.loader.systemd-boot.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
}
