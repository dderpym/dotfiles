{ ... }:

{
  # Noctalia has no ambient-light support, so wluma drives intel_backlight from
  # the IIO light sensor (exposed by the nixos-hardware Framework profile).
  services.wluma = {
    enable = true;
    settings = {
      step_delay = 10;
      als.iio = {
        path = "/sys/bus/iio/devices";
        thresholds = {
          "0" = "night";
          "20" = "dark";
          "80" = "dim";
          "250" = "normal";
          "500" = "bright";
          "800" = "outdoors";
        };
      };
      output.backlight = [{
        name = "eDP-1";
        path = "/sys/class/backlight/intel_backlight";
        capturer = "wayland";
      }];
    };
  };
}
