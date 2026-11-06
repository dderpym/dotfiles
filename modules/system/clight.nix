{ ... }:

{
  # Replaces wluma: clight reads the IIO light sensor and maps it through a
  # continuous curve (interpolated regression points) instead of wluma's
  # discrete lux buckets, which jumped whenever the sensor hovered on a
  # threshold. Doesn't learn; tune the curve below by hand.
  # The clight module asserts a location even though daytime/gamma are off
  # below; geoclue avoids hardcoding coordinates.
  location.provider = "geoclue2";

  services.clight = {
    enable = true;
    settings = {
      # Only the backlight-from-ALS part is wanted; Niri/Noctalia own the rest.
      gamma.disabled = true;
      daytime.disabled = true;
      dimmer.disabled = true;
      dpms.disabled = true;
      keyboard.disabled = true;
      screen.disabled = true;

      sensor = {
        # Pin the ALS so clight never falls back to the webcam.
        devname = "iio:device0";
        # clightd already puts lux on a log axis (index i = 10^(i/2) lux:
        # 1, 3, 10, 32, 100, 316, 1k, 3k, 10k, 32k, 100k), so a smoothly
        # rising curve here is log-in-lux. Anchored on a hand-picked point:
        # ~240 lux (index ~4.76) = 13.6% backlight; steepens outdoors.
        ac_regression_points = [ 0.02 0.03 0.05 0.08 0.11 0.145 0.25 0.42 0.65 0.85 1.0 ];
        batt_regression_points = [ 0.015 0.02 0.035 0.055 0.075 0.10 0.17 0.29 0.45 0.60 0.70 ];
      };

      backlight = {
        # Slow fixed-duration fade so level changes never look like a jump.
        trans_fixed = 2500;
        # Re-read the sensor often; the ALS is cheap (no webcam capture).
        ac_timeouts = [ 20 20 20 ];
        batt_timeouts = [ 30 30 30 ];
      };
    };
  };
}
