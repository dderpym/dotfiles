# KDE bugs 522117 / 522477: drkonqi-coredump-launcher crash-loops at logout.
#
# What happens: systemd-coredump hands every user-process crash to KDE's
# drkonqi-coredump-launcher (a QGuiApplication) via the
# drkonqi-coredump-launcher.socket. At logout the compositor socket is already
# dead and there is no X DISPLAY, so the launcher aborts inside the
# QGuiApplication constructor; its own core then re-triggers the coredump
# pipeline, which launches it again (the socket sets TriggerLimitBurst=0, so
# systemd does not rate-limit) — a self-sustaining loop until the session dies.
# On this machine every logout produced 13–15 launcher cores (28 total in
# /var/lib/systemd/coredump), triggered by xdg-desktop-portal-cosmic panicking
# on the dead wayland socket (pop-os/xdg-desktop-portal-cosmic#282). That
# portal has since been dropped (nemo replaced cosmic-files), so the *observed*
# trigger is gone — but the launcher loop is a drkonqi bug that fires on any
# user core, so the mask stays until we ship drkonqi ≥ 6.7.2.
#
# Why this module exists: the loop is fixed upstream in drkonqi commit
# b2971200 ("don't start launcher when not in a graphical session", 2026-07-10),
# but nixos-26.05 still ships drkonqi 6.6.6, which predates it. Rather than
# masking with `systemctl --user mask` (lost on every rebuild), we shadow the
# two units with inert ones of the same name — /etc/systemd/user wins over the
# plasma package's units in the profile, so the pipeline never spawns a GUI.
# Core dumps are preserved either way; only the KDE crash dialog is disabled.
#
# DELETE THIS MODULE once your channel ships the fix (drkonqi ≥ 6.7.2 / plasma
# 6.8+, or a 6.6.x backport). Verify before deleting:
#   systemctl --user cat drkonqi-coredump-launcher@.service
# — the unit should carry a graphical-session guard (Condition*/AssertPathExists)
# that b2971200 added. Until then the masked units are the KDE-documented
# workaround.
{ ... }:

{
  # Template service: every socket connection spawns one instance. The original
  # aborts with "could not connect to display" at logout; /bin/true exits
  # cleanly, so no core is produced and the loop cannot feed itself.
  systemd.user.units."drkonqi-coredump-launcher@.service" = {
    enable = true;
    text = ''
      [Unit]
      Description=Launch DrKonqi (masked — aborts with no display at logout; KDE bug 522477)
      PartOf=graphical-session.target
      ConditionUser=!@system

      [Service]
      ExecStart=/bin/true
      Restart=no
    '';
  };

  # Same name, different listen path: nothing ever accepts connections on the
  # real /run/user/1000/drkonqi-coredump-launcher path, so systemd-coredump's
  # notification fails harmlessly even if the service shadow is bypassed.
  systemd.user.units."drkonqi-coredump-launcher.socket" = {
    enable = true;
    text = ''
      [Unit]
      Description=DrKonqi launcher socket (masked — KDE bug 522477)
      DefaultDependencies=no
      ConditionUser=!@system

      [Socket]
      ListenSequentialPacket=/run/user/%U/drkonqi-coredump-launcher.disabled
      SocketMode=0600
      Accept=yes
    '';
  };
}
