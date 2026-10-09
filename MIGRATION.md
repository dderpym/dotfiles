# Moving the managed home

Git, SSH host settings, Neovim configuration and `Wallpapers/p4g.png` are
captured in this repository. Private keys and account credentials are not.

- Back up and restore `~/.ssh` and the complete `~/.gnupg` through an encrypted
  channel, preserving permissions. Keep the directories mode 0700 and private
  keys mode 0600. Never add them to this repository or a Nix `source`/`text`.
  Preserve `~/.gnupg/common.conf` too: the current keyring uses keyboxd.
- Git still signs commits with the existing OpenPGP key. Its private key must
  be restored before signing will work on a new laptop.
- SSH uses Home Manager's GPG-agent socket. Agent forwarding is disabled,
  including for `austin-1`; enable it for a specific invocation only if needed.
  Host-key verification remains enabled. `known_hosts` stays private/mutable.
- On activation, Home Manager backs up conflicting unmanaged files with the
  suffix `.before-home-manager`. It refuses to overwrite existing backups;
  review and archive them if a later switch reports a collision.
- After switching and confirming the GPG SSH socket works, disable the old
  manually installed agent on this laptop with
  `systemctl --user disable --now ssh-agent.service`. Do not copy that unit to
  the new laptop.
- Neovim's Lua files are managed in `modules/home/nvim`. Edit them here.
  `lazy-lock.json` and `lazyvim.json` are writable copies, seeded only when
  missing. After intentional plugin/extras updates, copy the updated files
  back into the repository if the next laptop should receive those updates.
  Plugin downloads and Mason installations still require network access;
  language SDKs and PlatformIO are project/dev-shell dependencies.
- Restore needed project data and `/media` separately. Regenerate hardware
  configuration and provision Secure Boot before using this on another host.

Run `python3 tests/check-home-migration.py` for isolated module/configuration
checks, then `nix flake check` and `nixos-rebuild build --flake .#stoletop`
before switching. The test does not touch your live home or connect over SSH.
