{ pkgs, osConfig, ... }:

let
  autobright = pkgs.runCommandCC "autobright" { } ''
    mkdir -p $out/bin
    $CC -O2 -Wall -Wextra -Werror \
      -DBACKLIGHT='"${osConfig.machine.backlight}"' \
      -DBRIGHTNESSCTL='"${pkgs.brightnessctl}/bin/brightnessctl"' \
      -o $out/bin/autobright ${./autobright.c} -lm
  '';
in
{
  # Replaces wluma and clight. wluma's lux buckets jumped at every threshold;
  # clight can only fit a parabola through points bounded to 0..1, which can't
  # pass through the hand-picked brightness points. This is a power curve
  # through those two points (2% floor in the dark) plus an offset the
  # brightness keys move (see autobright.c and the XF86MonBrightness binds in
  # niri.nix).
  home.packages = [ autobright ];

  systemd.user.services.autobright = {
    Unit = {
      Description = "Ambient light backlight (power curve + offset)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${autobright}/bin/autobright daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
