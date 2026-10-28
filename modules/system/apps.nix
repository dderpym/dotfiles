{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.default
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  virtualisation.docker = {
    enable = true;
    # Keep socket activation, but don't start dockerd on every boot.
    enableOnBoot = false;
  };

  # NIX COMPATIBILITY LAYERS
  services.envfs.enable = true;
  programs.nix-ld = {
    enable = true;
    # NOTE: setting `libraries` REPLACES the module's default list rather
    # than extending it, so the defaults (zstd, attr, libssh, bzip2, libxml2,
    # acl, libsodium, xz, ...) are restated at the top here — otherwise they
    # are silently lost.
    #
    # Renames to keep in mind on update:
    #   - libjpeg-turbo  -> libjpeg
    #   - libgbm         -> split out of mesa as its own package
    #   - xorg set deprecated: xorg.xcbutil* -> libxcb-*, xorg.libXt -> libxt,
    #     xorg.libXmu -> libxmu, xorg.libXft -> libxft, xorg.libxshmfence ->
    #     libxshmfence, xorg.libXxf86vm -> libxxf86vm
    #
    # Debugging: `nix-locate lib/libfoo.so.1 --top-level` (via comma) tells
    # you which package provides a missing library; `LD_DEBUG=libs` shows
    # what an unpatched binary actually tries to load.
    libraries = with pkgs; [
      # ── Module defaults (restored — see note above) ─────────────────────
      zlib
      zstd
      stdenv.cc.cc          # libstdc++.so.6 + libgcc_s.so.1
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux            # libuuid / libblkid / libmount
      xz
      systemd               # libudev.so.1 / libsystemd

      # ── Core system & toolchain ─────────────────────────────────────────
      glibc
      libgcc                # libgcc_s.so.1 (independent of stdenv.cc.cc)
      libcap
      libcap_ng
      libseccomp
      libselinux
      libsepol
      libapparmor
      keyutils
      libxcrypt             # libcrypt.so.1 for older binaries
      libunwind
      libffi
      pam
      cracklib
      libpwquality
      libtirpc
      libnsl                # libnsl.so.1 (split out of glibc ≥ 2.32)
      openldap
      libutempter
      gettext               # libintl.so.8
      readline
      ncurses
      libedit
      lzo
      snappy

      # ── Compression / archives ──────────────────────────────────────────
      libarchive
      libzip
      minizip-ng

      # ── Web / network / crypto ──────────────────────────────────────────
      gnutls
      nettle
      p11-kit
      libtasn1
      gmp
      libgcrypt
      libgpg-error
      libassuan
      libksba
      npth
      libssh2
      libkrb5
      libidn
      libidn2
      libunistring
      libpsl
      brotli
      nghttp2
      libsoup_3             # libsoup-3.0.so (GTK/GNOME apps)

      # ── Data formats / parsing ──────────────────────────────────────────
      sqlite
      expat
      libxslt
      libyaml
      yaml-cpp
      jsoncpp
      nlohmann_json
      rapidjson
      yajl
      jansson
      cjson
      pcre
      pcre2
      oniguruma
      re2

      # ── X11 / Wayland ───────────────────────────────────────────────────
      libx11
      libxcb
      libxcb-util
      libxcb-wm
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-cursor         # Qt6
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxinerama
      libxrandr
      libxrender
      libxtst
      libxscrnsaver
      libxshmfence
      libxxf86vm
      libxt
      libxmu
      libxft
      libice
      libsm
      libxkbcommon
      wayland

      # ── Graphics / GPU / video ──────────────────────────────────────────
      libGL                 # libglvnd: libGL / libEGL / libGLX
      libGLU
      mesa                  # DRI drivers / gallium
      libgbm                # libgbm.so.1 (standalone mesa split)
      libdrm
      vulkan-loader
      ocl-icd               # libOpenCL.so.1 (ICD loader)
      libva                 # VA-API (hw video decode)
      libvdpau
      libvdpau-va-gl
      libvpx
      libpng
      libjpeg               # renamed from libjpeg-turbo
      libtiff
      libwebp
      librsvg
      pixman
      harfbuzz
      fribidi

      # ── UI toolkit stack (GTK2/GTK3, Electron, Qt) ─────────────────────
      glib
      gtk2                  # legacy binaries still link GTK2
      gtk3
      gdk-pixbuf
      pango
      cairo
      atk
      at-spi2-core          # libatspi.so.0 (accessibility)
      at-spi2-atk           # libatk-bridge-2.0.so.0 (accessibility)
      dbus
      dbus-glib
      libnotify
      libappindicator-gtk3
      libayatana-appindicator # libayatana-appindicator3.so.1 (Electron trays)
      libdbusmenu-gtk3
      libcanberra-gtk3
      libgnome-keyring
      libsecret
      icu
      cups                  # libcups.so (printing in Electron apps)
      nspr
      nss

      # ── Fonts ───────────────────────────────────────────────────────────
      fontconfig
      freetype

      # ── Audio ───────────────────────────────────────────────────────────
      alsa-lib
      libpulseaudio
      pipewire
      openal
      portaudio
      libsndfile
      libsamplerate
      libogg
      libvorbis
      flac
      libopus
      speex
      libtheora
      libao
      sndio
      jack2
      liblo

      # ── Devices / hardware ──────────────────────────────────────────────
      libudev0-shim         # libudev.so.0 for legacy games
      libusb1
      libusb-compat-0_1
      hidapi
      bluez                 # libbluetooth.so
      libevdev
      libinput
      libwacom
      libraw1394
      libavc1394
      libdc1394
      libgphoto2
      libv4l
      libcec
      libmtp
      libusbmuxd
      libimobiledevice
      libnfs
      libiscsi

      # ── Media / playback ────────────────────────────────────────────────
      libvlc
      ffmpeg                # libavcodec/format/util for dlopening apps
      libmpeg2
      libdvdcss
      libdvdread
      libdvdnav
      libbluray
      libaacs
      libbdplus
      libcaca

      # ── SDL / games ─────────────────────────────────────────────────────
      SDL2
      SDL2_image
      SDL2_ttf
      SDL2_mixer
      freeglut
      glew
      tbb
      libmikmod
      libxmp
      libmodplug
      libopenmpt
      libsidplayfp
      game-music-emu        # renamed from libgme
      libebur128
      libsoundio
      libsbsms
      libltc

      # ── Misc / AppImage / net-tools ─────────────────────────────────────
      fuse                  # libfuse.so.2 (AppImages)
      fuse3
      e2fsprogs             # libext2fs / libcom_err
      sane-backends
      pkcs11helper
      libpcap
      libdnet
      libnet
      libmnl
      libnfnetlink
      libnftnl
      libnetfilter_conntrack
      libevent
      libev
      libuv
      libconfig

      # ── Steam FHS runtime (supplement, not replacement) ────────────────
      # Symlinks steam-run's whole /usr/lib64 into the nix-ld env. Measured
      # overlap with the curated list above: 326 shared / 160 curated-only /
      # 411 steam-only — so this ADDS libs (abseil split libs, game
      # middleware, dlopen-able codecs) without replacing anything.
      #   - Appended LAST on purpose: buildEnv keeps the first hit on name
      #     collisions (ignoreCollisions), so the curated versions above win;
      #     both come from the same nixpkgs rev anyway, so no version skew.
      #   - ~0 disk cost: the fhsenv rootfs is 12.6 MB of symlinks and every
      #     real library behind it is already in the system closure because
      #     programs.steam.enable pulls in steam-run's fhsenv.
      #   - Requires allowUnfree (already set in configuration.nix).
      # Recipe: https://wiki.nixos.org/wiki/Nix-ld + nixpkgs issue #354513
      (pkgs.runCommand "steamrun-lib" {} ''
        mkdir $out
        ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib
      '')
    ];
  };

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  services.openssh.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lm_sensors
    efibootmgr
    # Secure Boot key management + verification (sbctl status / verify / enroll-keys)
    sbctl
    git
    nano
    curl
    wget
    # pactl — volume/mute keys (client for the system-managed pipewire-pulse)
    pulseaudio
  ];

  programs.nix-index-database.comma.enable = true;
}
