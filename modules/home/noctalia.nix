{ config, lib, pkgs, unstable, ... }:

let
  noctalia = unstable.noctalia;
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
      start = [ "control-center" "bongocat" "active_window" "media" ];
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
          members = [ "cat" "ram" "temp" ];
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

      bongocat = {
        type = "noctalia/bongocat:cat";
        input_devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        executable_path = "evtest";
        audio_spectrum = true;
        tappy_mode = true;
        rave_mode=true;
      };

      volume = {
        icon_color = "tertiary";
        show_label = false;
        capsule_border = "tertiary";
        actions = {
          left = "panel-toggle stoletop/micropanels:volume";
          middle = "exec pwvucontrol || pavucontrol";
        };
      };

      brightness = {
        icon_color = "secondary";
        show_label = false;
        capsule_border = "secondary";
        actions = {
          left = "panel-toggle stoletop/micropanels:brightness";
        };
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

      # replaces the cpu sysmon widget: CPU load as a running cat (pace tracks
      # load, % readout on the right; click opens its own panel — the same cat
      # at panel size with the CPU percentage). Custom color = the palette
      # primary (mauve) the cpu icon used, so the group keeps its
      # primary/secondary/tertiary role mapping — theme mode would give
      # secondary (peach), clashing with ram.
      cat = {
        type = "dotnetrob/cat:cat";
        show_cpu_percent = true;
        cat_color_mode = "custom";
        cat_color = "#cba6f7";
      };

      ram = {
        type = "sysmon";
        stat = "ram_used";
        font_family = "monospace";
        color = "secondary";

        actions = { left = "panel-toggle stoletop/micropanels:system"; };
      };

      temp = {
        type = "sysmon";
        stat = "cpu_temp";
        font_family = "monospace";
        color = "tertiary";
        actions = { left = "panel-toggle stoletop/micropanels:system"; };
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
      # Native auth prompts inherit our Catppuccin palette without another agent.
      polkit_agent = true;

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
        control_center_placement = "floating";
        session_placement = "floating";
        session_position = "auto";
        open_near_click_control_center = true;
        open_near_click_session = true;
        open_near_click_clipboard = true;
        launcher_placement = "floating";
        launcher_position = "center";
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
      # Noctalia runs fprintd verification beside the password PAM thread.
      fingerprint = true;
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
      # opens that jump straight to a tab (notifications, power, network,
      # media bar widgets, `msg panel-toggle control-center <tab>`) drop the
      # sidebar entirely so they read as small panels, not the full center
      sidebar_section = "none";
      hidden_tabs = [ "monitor" ]; # brightness has its own popup now
      width = 600; # slimmest allowed; no-sidebar opens scale down from it
      calendar = { show_week_numbers = false; };
    };

    # --- PLUGINS ---
    plugins = {
      # noctalia/bongocat (official source): the typing cat bar widget that
      # replaced the control-center icon. dotnetrob/cat (community source): the
      # animated CPU cat bar widget that replaced the cpu sysmon widget. Local
      # Luau plugin (pkgs/noctalia-plugins): compact popups for volume /
      # brightness / system graphs that open under their bar widget.
      #
      # The whole dir is symlinked to ~/.local/share/noctalia/plugins (the
      # "local" path source) by the home.file below. The other two sources are
      # listed explicitly because setting plugins.source replaces the schema
      # defaults (official + community) instead of merging with them. This
      # beta.7 build discovers plugins via catalog.toml at each source root.
      enabled = [ "noctalia/bongocat" "dotnetrob/cat" "stoletop/micropanels" ];
      source = [
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = true;
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          enabled = true;
        }
        {
          name = "local";
          kind = "path";
          location = "${config.home.homeDirectory}/.local/share/noctalia/plugins";
          enabled = true;
        }
      ];
    };

    # --- HOOKS ---
    hooks = {
      # The daemon's plugin enable state lives in ~/.local/state/noctalia/
      # settings.toml (written by the `plugins enable` IPC) — the
      # [plugins].enabled list above is NOT consulted at startup (verified:
      # with the list present, a clean restart left the plugin off). So
      # re-assert the enable on every shell start: idempotent, and the flake
      # stays the source of truth even if the state file is reset.
      #
      # The started hook fires once IPC is ready, so no retry loop is needed.
      started = [
        "noctalia msg plugins enable noctalia/bongocat"
        "noctalia msg plugins enable dotnetrob/cat"
        "noctalia msg plugins enable stoletop/micropanels"
        "noctalia msg wallpaper-random"
      ];
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
      directory = "${config.home.homeDirectory}/Wallpapers";
      fill_mode = "crop";
      fill_color = "#1e1e2e";
      transition = [ "fade" "wipe" "disc" "stripes" "honeycomb" ];
      transition_duration = 1500;
      transition_on_startup = true;

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
  home.file."Wallpapers/p4g.png".source = ../../assets/wallpapers/p4g.png;

  xdg.configFile."noctalia/config.toml" = {
    force = true;
    source = validatedConfigToml;
  };

  # Custom scheme: Catppuccin Mocha with a true red error color — see
  # ./palettes/catppuccin-traffic.nix for the palette itself.
  xdg.configFile."noctalia/palettes/Catppuccin-Traffic.json" = {
    text = builtins.toJSON (import ./palettes/catppuccin-traffic.nix);
  };

  # Local Luau plugin with the compact popups (volume / brightness / system
  # graphs). Single symlink of the whole source dir — which is also the
  # "local" path source location declared in [plugins].source above — so the
  # plugin files and its catalog.toml travel together.
  home.file.".local/share/noctalia/plugins" = {
    source = ../../pkgs/noctalia-plugins;
  };

  # Heal the plugin enable state at switch time too (see hooks.started above):
  # the enable lives in the daemon's state file, so run the same idempotent
  # enables after activation — a state reset is fixed immediately instead of
  # waiting for the next noctalia start. Absolute path: the activation env
  # may not have the user profile on PATH.
  home.activation.ensurePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${config.home.profileDirectory}/bin/noctalia msg plugins enable noctalia/bongocat >/dev/null 2>&1 || true
    ${config.home.profileDirectory}/bin/noctalia msg plugins enable dotnetrob/cat >/dev/null 2>&1 || true
    ${config.home.profileDirectory}/bin/noctalia msg plugins enable stoletop/micropanels >/dev/null 2>&1 || true
  '';
}
