# Migration guide

How to take this config (`stoletop`, a Framework 13 Pro running NixOS 26.05 +
niri + noctalia) and make it yours. It is a personal laptop config, not a
distro: expect to fork it, delete things, and change a handful of
machine-specific values before it will boot on your hardware.

> **Read this first.** Do not copy `hardware-configuration.nix`, the btrfs
> layout, or the `resume_offset` from this repo. They describe *my* disk. A
> wrong value there gives you an unbootable system or broken hibernate.

## What you get

| Layer | What it is |
|-------|------------|
| Desktop | [niri](https://github.com/YaLTeR/niri) (scrollable-tiling Wayland compositor) via `niri-flake`, SDDM login, [noctalia](https://github.com/noctalia-dev/noctalia-shell) bar/launcher/lockscreen |
| Theme | Catppuccin mocha/blue everywhere (`catppuccin/nix`) |
| Boot | Secure Boot via lanzaboote (signed UKIs), `linuxPackages_latest` |
| Storage | btrfs subvolumes (`@root @home @nix @snapshots @swap`), zstd, swapfile + zram, hibernate |
| Power | `power-profiles-daemon` switched by AC state, lid = suspend-then-hibernate |
| Shell | bash + flyline + starship, neovim (LazyVim), kitty |
| Extras | Tailscale, Docker, libvirt/QEMU, Steam, nix-ld + envfs, GPG-agent as SSH agent |
| AI tooling | `claude-code` and `pi` with pinned skills (optional, see below) |

## Layout

```
flake.nix                  inputs + the single nixosConfiguration "stoletop"
configuration.nix          imports everything; sets stateVersion
hardware-configuration.nix GENERATED, machine-specific: replace
modules/system/            NixOS-level config (boot, hardware, display, nix, ...)
  machine.nix              custom options shared with home-manager (config.machine.*)
modules/home/              home-manager config for the user (shell, niri, noctalia, ...)
pkgs/                      local packages (flyline HM module, niri-shot, noctalia plugin)
assets/                    wallpaper, pinentry icon
```

`modules/home/default.nix` is where the user is declared and every home module
is imported. Remove a line there to drop a module.

## Before you start

- A NixOS install (any recent release is fine; this config targets 26.05). The
  installer's guided btrfs layout is not required, but see
  [Disk layout](#3-disk-layout).
- Flakes enabled for the first build:
  `nix --extra-experimental-features 'nix-command flakes' ...`
  (this config enables them permanently in `modules/system/nix.nix`).
- Optional but recommended: leave Secure Boot **off** until the rest works.
  Add it last ([Secure Boot](#5-secure-boot-lanzaboote)).

## Step by step

### 1. Fork and clone

```sh
git clone <your-fork> ~/dotfiles && cd ~/dotfiles
```

### 2. Rename the user and host

The username `stoler` (UID 1000) is hardcoded in several places. Grep for it:

```sh
grep -rn "stoler" --include=*.nix .
```

Expect hits in:

| File | What |
|------|------|
| `modules/home/default.nix` | `users.users.stoler`, `home-manager.users.stoler` |
| `modules/system/boot.nix` | `home-manager-stoler.service`, and `user@1000` (UID 1000: correct if you are the first user) |
| `modules/home/noctalia.nix` | `avatar_path = "/home/stoler/.face"`: use `config.home.homeDirectory` or just change the path |
| `flake.nix` | `nixosConfigurations.stoletop`, and the `description` |
| `modules/system/networking.nix` | `networking.hostName` |

If you rename the host, rebuild with `--flake .#<newhost>`. `nixos-rebuild`
picks the config matching your hostname when no `#name` is given.

Also in `modules/home/default.nix`, review `extraGroups`. `docker`, `libvirtd`,
`gamemode`, and `input` only matter if you keep those features (and `docker` is
effectively root, so don't add it by reflex).

### 3. Disk layout

`hardware-configuration.nix` is generated from the machine it was installed on.
**Regenerate it on your laptop** and overwrite the one in the repo:

```sh
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Things in this repo that assume my layout, and need adjusting:

- **Filesystems.** Mine is a single btrfs volume with subvolumes mounted at
  `/`, `/home`, `/nix`, `/.snapshots`, `/swap`, plus a second btrfs disk at
  `/mnt/media`. If your install is ext4 or has no `/mnt/media`, then:
  - `modules/system/hardware.nix`: `services.btrfs.autoScrub` lists
    `fileSystems = [ "/" "/mnt/media" ]`. Remove entries you don't have, or
    drop the block entirely if you aren't on btrfs.
- **`machine.rootDevice`** (`modules/system/machine.nix`) is derived from
  `fileSystems."/"`, so it follows your generated file automatically.
- **Swap + hibernate.** `modules/system/hardware.nix` sets
  `boot.kernelParams = [ "resume_offset=6386453" ]`. That number is specific to
  my swapfile on my filesystem. Either:
  - delete the line and `boot.resumeDevice` (no hibernate; lid becomes plain
    suspend: also change `HandleLidSwitch*` away from `suspend-then-hibernate`
    and drop `HibernateDelaySec`), or
  - compute your own after the swapfile exists:
    ```sh
    sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
    ```
    On btrfs the swapfile must be `nodatacow`, on its own subvolume (not
    snapshotted), and not compressed. `swapDevices` in the generated file is
    where it's declared. Recompute the offset any time you recreate the file.
- **zram** is independent of all of this and safe to keep.

### 4. Hardware-specific bits

This is the "Framework 13 Pro, Panther Lake" part. If you have a different
machine, go through each:

| Where | What it does | Action on other hardware |
|-------|--------------|--------------------------|
| `flake.nix` (`nixos-hardware` + the module in `modules = [...]`) | Framework 13 Core Ultra Series 3 profile: fwupd, fingerprint, TRIM, sensors | Swap for your model from the [nixos-hardware list](https://github.com/NixOS/nixos-hardware), or remove both |
| `hardware-configuration.nix` (`hardware.cpu.intel.npu`, `intel-media-driver`, `kvm-intel`) | Intel-specific | Regenerate; AMD users need `kvm-amd` and different graphics packages |
| `modules/system/machine.nix` | `backlight = "intel_backlight"`, keyboard evdev path, PCI addresses of USB controllers | See below |
| `modules/system/boot.nix` | `linuxPackages_latest` for Panther Lake support | Fine to keep, or switch to the default kernel if you don't need new hardware support |
| `modules/system/hardware.nix` | `fprintAuth` PAM tweaks, wakeup udev rule, power profile switching | Remove fprintd lines if you have no reader |
| `modules/home/autobright.nix` + `autobright.c` | Ambient-light-sensor auto brightness (needs an ALS and a backlight) | Remove the import in `modules/home/default.nix` and the `XF86MonBrightness` binds in `niri.nix` if you have no sensor, or use plain `brightnessctl` |

**The `machine` options** are the place to put per-machine values. Find yours:

```sh
ls /sys/class/backlight/                          # backlight name
ls /dev/input/by-path/ | grep kbd                 # built-in keyboard (only feeds the bongocat bar widget in noctalia)
lspci | grep -i xhci                              # xHCI controller addresses, e.g. 00:14.0
```

Set them in a host-local module or directly in `machine.nix`. Note that
`lspci` prints `00:14.0`, while the option wants the full form `0000:00:14.0`.

`externalUsbControllers` exists because on my laptop the built-in keyboard is
PS/2 and external USB devices are prevented from waking the machine. If you
don't want that behavior, set it to `[ ]` or delete the udev rule.

### 5. Secure Boot (lanzaboote)

This config **replaces systemd-boot with lanzaboote** (`modules/system/boot.nix`).
It's the riskiest part to adopt, so do it as a separate step:

1. First boot your fork *without* it. Comment out `lanzaboote.nixosModules.lanzaboote`
   in `flake.nix` and the `boot.lanzaboote` / `systemd-boot.enable = mkForce false`
   lines in `boot.nix`, and enable plain `boot.loader.systemd-boot.enable = true;`.
2. Once that works, create keys and switch over. The usual sequence from the
   [lanzaboote quick start](https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html):
   ```sh
   sudo sbctl create-keys        # writes /var/lib/sbctl (matches pkiBundle)
   ```
   re-enable the lanzaboote lines, `nixos-rebuild switch`, then check
   ```sh
   sudo sbctl verify             # everything should be signed
   ```
3. Put the firmware in Secure Boot **setup mode** (on Framework: BIOS ->
   Administer Secure Boot -> erase/reset keys; wording varies by firmware),
   then:
   ```sh
   sudo sbctl enroll-keys --microsoft
   ```
   `--microsoft` keeps Microsoft's keys so firmware option ROMs and dual-boot
   still work. Reboot and confirm with `bootctl status`.

If you don't care about Secure Boot, skip it permanently and stay on
systemd-boot. Nothing else in the config depends on it.

Also: `boot.loader.timeout = 0` boots straight in. Hold space at power-on to
get the menu. Delete that line if you'd rather see it.

### 6. Personal data to replace

These are mine; leaving them means your commits are signed as me (they won't
be, since you lack my key, so commits will just fail).

| File | Replace |
|------|---------|
| `modules/home/git.nix` | `user.name`, `user.email`, `signingKey`. Drop `commit.gpgSign` and `gpg.format` if you don't sign. `core.sshCommand` points at `~/.ssh/id_rsa`; use whichever key you have |
| `modules/home/ssh.nix` | The `austin-1`, `calsol`, `birdwax`, `ostrichwax` hosts are mine. Delete them. Also the `github.com` `IdentityFile` |
| `modules/home/gpg.nix` | Keep if you want gpg-agent as your SSH agent (it sets `IdentityAgent`). The pinentry patch is cosmetic only (cat icon). Replace with `pkgs.pinentry-qt` or similar if you want less to maintain |
| `modules/system/locale.nix` | `time.timeZone`, `i18n.defaultLocale` |
| `modules/system/networking.nix` | Tailscale. Remove the `services.tailscale` lines if you don't use it, and the `checkReversePath = "loose"` that exists only for exit-node traffic |
| `modules/home/noctalia.nix` | Avatar path, and `plugins.enabled` list |
| `modules/home/mimeapps.nix`, `niri.nix` | Default apps and keybinds, to taste. `Mod+Return` etc. are all in `niri.nix` |

If you do want signed commits, generate a key first
(`gpg --full-generate-key`), then put its long key ID in `signingKey` and
upload the public key to GitHub.

### 7. Binary caches (so the first build doesn't compile the world)

`flake.nix` declares extra substituters (`cache.numtide.com`, `catppuccin.cachix.org`).
Flakes ask you to confirm `nixConfig` interactively on first use. Say yes, or
the daemon never trusts them. `modules/system/nix.nix` persists the catppuccin
one so it also applies for daemon builds.

Without these, expect `claude-code`/`pi` and the catppuccin themes to build
from source, which is slow.

### 8. Trim what you don't want

Safe to delete wholesale (each is an independent module):

- **AI tooling:** `claude.nix`, `pi.nix` (and their imports in `default.nix`;
  then the `llm-agents`, `mattpocock-skills`, `ponytail` inputs in `flake.nix`).
  `pi.nix` defaults to a DeepSeek provider and `claude.nix` pins a model and
  disables a lot of Claude Code features. These are my preferences, not
  requirements. Read them before keeping them.
- **Neovim:** `neovim.nix` + `modules/home/nvim/` (LazyVim). The `plugins/`
  directory has a few things specific to me (Codeforces, PlatformIO).
- **Gaming:** `programs.steam`, `gamemode`, `prismlauncher`, `lutris`, `wine*`
  in `apps.nix` / `packages.nix`.
- **Virtualisation:** `modules/system/virtualisation.nix` (remove from
  `configuration.nix` imports; drop `libvirtd` from `extraGroups`).
- **Docker:** the `virtualisation.docker` block in `apps.nix`, `lazydocker`.
- **nix-ld library list:** the 300-line `programs.nix-ld.libraries` in
  `apps.nix` is a kitchen-sink so unpatched binaries just work. Trim it to the
  defaults if you don't run random prebuilt binaries.
- **`nix-alien`**: runs prebuilt binaries in an FHS env. Optional.
- **`vesktop`, `slack`**, and the rest of `packages.nix`: edit the list.

After removing a flake input, run `nix flake lock` to prune it.

### 9. `stateVersion`

`system.stateVersion` and `home.stateVersion` are `"25.11"`. That is the
release **I** first installed, not a recommendation. Set both to the NixOS
release you installed from, and **never bump them** afterwards, even when you
upgrade NixOS. See the comment in `configuration.nix`.

## Build and switch

Go up the ladder only as far as you need. Each step catches different things:

```sh
nix flake lock                                    # inputs resolve
nix flake check                                   # eval errors, unknown options
sudo nixos-rebuild build --flake .#<host>         # actually builds; catches generated-config errors
sudo nixos-rebuild test  --flake .#<host>         # activates without touching the bootloader
sudo nixos-rebuild switch --flake .#<host>
```

Use `test` before the first `switch`: if the session is broken, a reboot goes
back to your old generation. Keep your original `/etc/nixos` config around
until you've booted into the new one.

Notes:

- `nix flake check` does **not** run builders. Failures in generated files
  (e.g. `nix.conf`) only show at `build`.
- `home-manager.backupFileExtension = "before-home-manager"` means existing
  dotfiles (`~/.gitconfig`, `~/.config/...`) are renamed to `*.before-home-manager`
  on first activation, not overwritten. If activation fails because a backup
  already exists, delete the stale backup and re-run.
- Flake builds only see **git-tracked** files. `git add` new files before
  building or you'll get "path does not exist".
- Run builds from the repo directory; the first `nix flake lock` after editing
  the `pkgs/flyline` path input can fail with a transient git error. Re-run it.

## After the first boot

- **Log in via SDDM -> niri.** Noctalia is launched from niri's
  `spawn-at-startup`. If the bar is missing, `journalctl --user -b` and run
  `noctalia` in a terminal to see why.
- **Wallpaper.** `assets/wallpapers/p4g.png` is installed to `~/Wallpapers/`;
  add your own and adjust the `wallpaper` section of `noctalia.nix`.
- **Fingerprint:** `fprintd-enroll`. The lockscreen drives fprintd directly.
- **Tailscale:** `sudo tailscale up`.
- **Docker/libvirt groups** need a re-login to take effect.
- **Updating:** `nix flake update`, then build and switch. Roll back from the
  boot menu or with `sudo nixos-rebuild switch --rollback`.

## Things that are weird on purpose

Before "fixing" these, read the comments and `git log` for the reason:

- `nixpkgs-unstable` is a **second** nixpkgs, used only for `noctalia` (v5 is
  not in 26.05).
- `llm-agents`, `nix-alien`, and `catppuccin` deliberately have **no `follows`**
  on nixpkgs, to keep hitting their own binary caches or because upstream says
  overriding is unsupported. Making them follow will silently force source
  builds.
- The `systemd.services.home-manager-stoler` / `user@1000` dropins in
  `boot.nix` only reorder boot for faster login; they're safe to remove.
- The `systemd.tty.rows/columns` kernel params and the NetworkManager
  `Type = "exec"` override are boot-time micro-optimizations with comments
  explaining themselves.
- `claude.nix` and `pi.nix` install `settings.json` as a *writable copy* at
  activation (not a store symlink) because the tools write to it.

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| `error: path '.../foo.nix' does not exist` | File not `git add`ed |
| Boots to emergency shell, mentions a UUID | Stale `hardware-configuration.nix`; regenerate |
| Hibernate resumes into a fresh boot | Wrong `resume_offset`, or swapfile isn't `nodatacow` |
| Won't boot after enabling lanzaboote | Pick an old generation from the menu; check `sbctl verify` and that keys exist in `/var/lib/sbctl` |
| `sbctl enroll-keys` refuses | Firmware not in setup mode |
| Brightness keys do nothing | `autobright` has no sensor/backlight; check `machine.backlight` and `systemctl --user status autobright` |
| Everything compiles from source | Substituters not trusted; re-run with `--accept-flake-config` or confirm the prompt |
| Steam/Electron app missing a `.so` | `nix-locate lib/libfoo.so.1` (via `, `) and add it to `programs.nix-ld.libraries` |
| A module option "does not exist" | You're on a different nixpkgs release than 26.05; check your `flake.lock` and the matching manual |
