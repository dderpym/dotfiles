{ ... }:

{
  # nvme0n1p5 is LUKS2; the btrfs inside keeps its pre-encryption UUID
  # (mkfs.btrfs -U), so fileSystems.* in hardware-configuration.nix and the
  # resume= UUID stay valid. The LUKS UUID is chosen up front (luksFormat
  # --uuid) so this generation can be built and installed before the disk is
  # converted. Unlock is TPM2 (PCR 7) once enrolled; passphrase is the fallback.
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/09277d13-d8a2-4b6c-b40e-21efb2884cd8";
    # NVMe: skip dm-crypt's extra queues (latency) and pass TRIM through.
    bypassWorkqueues = true;
    allowDiscards = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
}
