{ config, lib, pkgs, inputs, ... }:

let
  noctalia = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.noctalia;
  tomlFormat = pkgs.formats.toml { };
  configToml = tomlFormat.generate "noctalia-config.toml" {
    # --- THEME ---
    # Custom Catppuccin palette with a true-red error color (see
    # palettes/Catppuccin-Traffic.json) — mirrors the v4 colorscheme.
    theme = {
      mode = "dark";
      source = "custom";
      custom_palette = "Catppuccin-Traffic";
    };

    bar.default = {
      position = "top";
      enabled = true;
      auto_hide = false;
      show_on_workspace_switch = true;
      reserve_space = true;
      layer = "top";
      thickness = 34;
      # invisible bar: no background, no border, no shadow — the square
      # widget capsules are the only visible ink
      background_opacity = 0;
      radius = 0;
      shadow = false;
      margin_edge = 0;
      margin_ends = 0;
      padding = 6;
      widget_spacing = 6;
      hover_highlight = true;
      scale = 1.0;
      font_weight = 500;
      capsule = true;
      capsule_fill = "surface_variant";
      capsule_opacity = 1;
      capsule_radius = 0;
      capsule_border = "outline";
      start = [ "control-center" "active_window" "media" ];
      center = [ "workspaces" ];
      end = [
        "tray"
        "volume"
        "brightness"
        "battery"
        "group:sysmon"
        "clock"
        "notifications"
        "clipboard"
        "session"
      ];

      capsule_group = [
        {
          id = "sysmon";
          members = [ "cpu" "ram" "temp" ];
          # square shared capsule; primary border matches the control-center
          # accent, members carry their own icon colors below
          radius = 0;
          border = "primary";
        }
      ];
    };

    # --- WIDGETS ---
    widget = {
      workspaces = {
        labels_only_when_occupied = true;
        hide_when_empty = true;
        focused_color = "primary";
        occupied_color = "outline";
        empty_color = "outline";
        urgent_color = "error";
        font_weight = 700;
      };

      active_window = {
        display = "icon_and_text";
        max_length = 320;
        title_scroll = "on_hover";
      };

      media = {
        hide_when_no_media = true;
        artist_first = true;
        title_scroll = "on_hover";
        max_length = 300;
      };

      tray = { drawer = true; };

      # accent: the entry point to the shell
      "control-center" = {
        icon_color = "primary";
        capsule_border = "primary";
      };

      volume = {
        icon_color = "tertiary";
        show_label = false;
        capsule_border = "tertiary";
        actions = { middle = "exec pwvucontrol || pavucontrol"; };
      };

      brightness = {
        icon_color = "secondary";
        show_label = false;
        capsule_border = "secondary";
      };

      battery = {
        display_mode = "graphic";
        device = "auto";
      };

      session = {
        # power menu gets the error color: destructive actions live here
        icon_color = "error";
        capsule_border = "error";
      };

      cpu = {
        type = "sysmon";
        stat = "cpu_usage";
        font_family = "monospace";
        icon_color = "primary";
      };

      ram = {
        type = "sysmon";
        stat = "ram_used";
        font_family = "monospace";
        icon_color = "secondary";
      };

      temp = {
        type = "sysmon";
        stat = "cpu_temp";
        font_family = "monospace";
        icon_color = "tertiary";
      };

      clock = {
        format = "{:%H:%M}";
        tooltip_format = "{:%H:%M %a, %b %d}";
        # blue "now" readout — hover is the only blue role in this palette
        color = "hover";
        capsule_border = "hover";
        font_weight = 700;
      };
    };

    shell = {
      # square all shell surfaces (launcher, control center, notifications,
      # OSD, popups) to match the bar; 0 = square, 1 = default
      corner_radius_scale = 0;
      button_borders = true;
      input_borders = true;
      popup_borders = true;
      card_borders = true;

      avatar_path = "/home/stoler/.face";
      font_family = "Sans Serif";
      time_format = "{:%H:%M}";
      setup_wizard_enabled = false;
      telemetry_enabled = false;
      clipboard_enabled = true;
      clipboard_history_max_entries = 100;
      clipboard_keep_from_closed_apps = true;
      clipboard_auto_paste = "off";

      animation = {
        enabled = true;
        speed = 1.0;
      };

      shadow = {
        direction = "down_right";
        alpha = 0.55;
      };

      launcher = {
        categories = true;
        show_icons = true;
        compact = false;
        app_grid = false;
        sort_by_usage = true;
        fetch_exchange_rates = true;
        provider_prefix = "/";
        auto_paste = "off";

        providers = {
          session = { global = true; };
          windows = { global = true; };
        };
      };

      panel = {
        session_placement = "floating";
        session_position = "center";
        # keep the outline on floating panels so square cards read as blocks
        borders = true;
      };

      mpris = { blacklist = [ ]; };

      screen_corners = { enabled = false; };

      session.actions = [
        {
          action = "lock";
          enabled = true;
          shortcut = "1";
        }
        {
          action = "logout";
          enabled = true;
          shortcut = "2";
        }
        {
          action = "lock_and_suspend";
          enabled = true;
          shortcut = "3";
          countdown_seconds = 10.0;
        }
        {
          action = "reboot";
          enabled = true;
          shortcut = "4";
          countdown_seconds = 10.0;
        }
        {
          action = "shutdown";
          enabled = true;
          shortcut = "5";
          variant = "destructive";
          countdown_seconds = 10.0;
        }
      ];
    };

    # --- IDLE (noctalia owns idle/suspend; timeouts are the single source of
    idle = {
      behavior_order = [ "lock" "screen-off" "lock-and-suspend" ];
      pre_action_fade_seconds = 5.0;

      behavior = {
        lock = {
          enabled = true;
          timeout = 660;
        };
        "screen-off" = {
          enabled = true;
          timeout = 600;
        };
        "lock-and-suspend" = {
          enabled = true;
          timeout = 1800;
        };
      };
    };

    # --- LOCKSCREEN ---
    lockscreen = {
      enabled = true;
      # v4 allowPasswordWithFprintd = false
      fingerprint = false;
      # v4 lockScreenBlur = 0 / lockScreenTint = 0
      blur_intensity = 0.0;
      tint_intensity = 0.0;
      # NOTE: beta.7 locks before logind suspend by default; the schema doesn't
      # expose lock_before_suspend yet (docs-only), so leave it unset.
    };

    # --- NOTIFICATIONS ---
    notification = {
      enable_daemon = true;
      position = "top_right";
      background_opacity = 0.95;
      border = true;
      collapse_on_dismiss = true;
    };

    # --- OSD ---
    osd = {
      enabled = true;
      position = "top_right";
      position_vertical = "top_right";
      border = true; # square OSD cards keep their outline
    };

    # --- AUDIO ---
    audio = {
      enable_overdrive = false;
      enable_sounds = false;
      sound_volume = 0.5;
    };

    # --- BRIGHTNESS ---
    brightness = {
      enable_ddcutil = false;
      minimum_brightness = 0.0;
      sync_all_monitors = false;
    };

    # --- NIGHT LIGHT (v4 autoSchedule with manual times) ---
    nightlight = {
      enabled = false;
      force = false;
      temperature_day = 6500;
      temperature_night = 4000;
    };

    # --- LOCATION / WEATHER ---
    location = {
      auto_locate = true;
      custom_schedule = true;
      sunrise = "06:30";
      sunset = "18:30";
    };

    weather = {
      enabled = true;
      effects = true;
      refresh_minutes = 30;
      unit = "metric";
    };

    # --- CONTROL CENTER ---
    control_center = {
      sidebar = "compact";
      sidebar_section = "compact";
      hidden_tabs = [ "monitor" ];
      calendar = { show_week_numbers = false; };
    };

    # --- SYSTEM MONITOR (traffic-light thresholds carried over from v4) ---
    system.monitor = {
      cpu_usage_activity_threshold = 80;
      cpu_usage_critical_threshold = 90;
      cpu_temp_activity_threshold = 80;
      cpu_temp_critical_threshold = 90;
      ram_pct_activity_threshold = 80;
      ram_pct_critical_threshold = 90;
      swap_pct_activity_threshold = 80;
      swap_pct_critical_threshold = 90;
      disk_used_pct_activity_threshold = 80;
      disk_used_pct_critical_threshold = 90;
      disk_free_pct_activity_threshold = 20;
      disk_free_pct_critical_threshold = 10;
      gpu_usage_activity_threshold = 80;
      gpu_usage_critical_threshold = 90;
      gpu_temp_activity_threshold = 80;
      gpu_temp_critical_threshold = 90;
    };

    battery = { warning_threshold = 20; };

    dock = {
      enabled = false;
      pinned = [ "kitty.desktop" "firefox.desktop" "vesktop.desktop" "slack.desktop" ];
    };

    desktop_widgets = { enabled = false; };

    backdrop = { enabled = false; };

    wallpaper = {
      enabled = true;
      directory = "/home/stoler/Pictures/Wallpapers";
      fill_mode = "crop";
      fill_color = "#1e1e2e";
      transition = [ "fade" "wipe" "disc" "stripes" "honeycomb" ];
      transition_duration = 1500;
      # v4 skipStartupTransition = false → animate the first wallpaper at startup
      transition_on_startup = true;
      edge_smoothness = 0.05;

      automation = {
        enabled = false;
        interval_seconds = 300;
        order = "alphabetical";
        recursive = true;
      };
    };

    calendar = { enabled = false; };
  };

  validatedConfigToml = pkgs.runCommand "noctalia-config-validated.toml" { } ''
    ${lib.getExe noctalia} config validate ${configToml} >/dev/null
    cp ${configToml} $out
  '';
in
{
  xdg.configFile."noctalia/config.toml" = {
    force = true;
    source = validatedConfigToml;
  };

  # Custom scheme: Catppuccin Mocha with a true red error color. The bundled
  # Catppuccin "red" (#f38ba8) reads pink on dark — it drives the battery's
  # low/critical state and the sysmon critical color. Palette is otherwise
  # identical to the bundled Catppuccin; only dark mError and dark mHover
  # change (hover: teal #94e2d5 → mocha blue #89b4fa).
  #
  # v5 keeps the v4 colorscheme JSON format verbatim, just under palettes/
  # instead of colorschemes/ (selected via [theme] source/custom_palette).
  xdg.configFile."noctalia/palettes/Catppuccin-Traffic.json" = {
    text = builtins.toJSON {
      dark = {
        mPrimary = "#cba6f7";
        mOnPrimary = "#11111b";
        mSecondary = "#fab387";
        mOnSecondary = "#11111b";
        mTertiary = "#94e2d5";
        mOnTertiary = "#11111b";
        mError = "#f38ba8";
        mOnError = "#11111b";
        mSurface = "#1e1e2e";
        mOnSurface = "#cdd6f4";
        mSurfaceVariant = "#313244";
        mOnSurfaceVariant = "#a3b4eb";
        mOutline = "#4c4f69";
        mShadow = "#11111b";
        mHover = "#89b4fa";
        mOnHover = "#11111b";
        terminal = {
          normal = {
            black = "#45475a";
            red = "#f38ba8";
            green = "#a6e3a1";
            yellow = "#f9e2af";
            blue = "#89b4fa";
            magenta = "#f5c2e7";
            cyan = "#94e2d5";
            white = "#a6adc8";
          };
          bright = {
            black = "#585b70";
            red = "#f37799";
            green = "#89d88b";
            yellow = "#ebd391";
            blue = "#74a8fc";
            magenta = "#f2aede";
            cyan = "#6bd7ca";
            white = "#bac2de";
          };
          foreground = "#cdd6f4";
          background = "#1e1e2e";
          selectionFg = "#cdd6f4";
          selectionBg = "#585b70";
          cursorText = "#1e1e2e";
          cursor = "#f5e0dc";
        };
      };
      light = {
        mPrimary = "#8839ef";
        mOnPrimary = "#eff1f5";
        mSecondary = "#fe640b";
        mOnSecondary = "#eff1f5";
        mTertiary = "#40a02b";
        mOnTertiary = "#eff1f5";
        mError = "#d20f39"; # already a true red in light mode
        mOnError = "#dce0e8";
        mSurface = "#eff1f5";
        mOnSurface = "#4c4f69";
        mSurfaceVariant = "#ccd0da";
        mOnSurfaceVariant = "#6c6f85";
        mOutline = "#a5adcb";
        mShadow = "#dce0e8";
        mHover = "#40a02b";
        mOnHover = "#eff1f5";
        terminal = {
          normal = {
            black = "#51576d";
            red = "#e78284";
            green = "#a6d189";
            yellow = "#e5c890";
            blue = "#8caaee";
            magenta = "#f4b8e4";
            cyan = "#81c8be";
            white = "#a5adce";
          };
          bright = {
            black = "#626880";
            red = "#e67172";
            green = "#8ec772";
            yellow = "#d9ba73";
            blue = "#7b9ef0";
            magenta = "#f2a4db";
            cyan = "#5abfb5";
            white = "#b5bfe2";
          };
          foreground = "#c6d0f5";
          background = "#303446";
          selectionFg = "#c6d0f5";
          selectionBg = "#626880";
          cursorText = "#303446";
          cursor = "#f2d5cf";
        };
      };
    };
  };
}
