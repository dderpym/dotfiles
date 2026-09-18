{ pkgs, ... }:

{
  # Local VMs: KVM acceleration + QEMU, managed through libvirt.
  #
  # KVM side needs nothing here: hardware-configuration.nix already loads the
  # `kvm-intel` kernel module (Intel VT-x, auto-detected at install time), so
  # /dev/kvm appears at boot.
  #
  # libvirtd is the manager (virsh / virt-manager). Its module pulls in QEMU
  # — default `pkgs.qemu`, full emulation incl. other arches; swap to
  # `virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm` only if you never
  # want to emulate non-x86 targets. QEMU runs as root by default
  # (`qemu.runAsRoot` stays true), so no /dev/kvm or image-ownership fiddling.
  
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ passt ];
  };
  virtualisation.spiceUSBRedirection.enable = true;

  # GUI tools. virsh + qemu-img + qemu-system-* already land on PATH via the
  # libvirtd module itself. GUI apps usually live in home-manager packages,
  # but virt-manager is grouped here with its daemon since it manages the
  # system libvirtd.
  environment.systemPackages = with pkgs; [
    passt
    virt-manager # GTK manager: create/start/stop VMs, embedded spice console
    virt-viewer  # standalone console client (remote-viewer), external consoles
  ];

}
