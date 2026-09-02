{ lib, ... }:

{
  # Lanzaboote replaces systemd-boot: it signs the kernel, initrd and boot
  # loader with the db key and installs UKIs + its own systemd-boot loader
  # entries. systemd-boot must stay disabled (docs force it off).
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    # sbctl key bundle (created with `sudo sbctl create-keys`): keys/ + GUID.
    # lzbt reads db.pem/db.key from here at switch time to sign the ESP
    # artifacts. NOTE: this machine dual-boots Windows (BitLocker), so enroll
    # the Microsoft keys too when enabling Secure Boot:
    #   sudo sbctl enroll-keys --microsoft
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
