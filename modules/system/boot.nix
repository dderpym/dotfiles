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

  # home-manager orders its activation Before=systemd-user-sessions, so the
  # SDDM greeter waited ~1.3s for it on every boot. Activation re-applies an
  # already-applied generation at boot, so let it run during the greeter and
  # gate the session instead: user@1000 (the user manager, started by PAM at
  # login) waits for it. Single-user machine with no autologin; other users and
  # SSH are not held back.
  systemd.services.home-manager-stoler.before = lib.mkForce [ ];
  systemd.services."user@1000" = {
    overrideStrategy = "asDropin";
    after = [ "home-manager-stoler.service" ];
  };
}
