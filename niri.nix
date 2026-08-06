{ config, lib, pkgs, ... }:

let
  barNoBlurRule = ''
    layer-rule {
        match namespace="noctalia-bar-default"
        background-effect {
            blur false
        }
    }
  '';

  niriConfig = config.programs.niri.finalConfig + "\n" + barNoBlurRule;
  validatedNiriConfig = pkgs.runCommand "niri-config.kdl" {
    inherit niriConfig;
    passAsFile = [ "niriConfig" ];
    buildInputs = [ pkgs.niri ];
  } ''
    niri validate -c $niriConfigPath
    cp $niriConfigPath $out
  '';
in
{
  programs.niri.package = pkgs.niri;

  xdg.configFile."niri-config" = {
    source = lib.mkForce validatedNiriConfig;
  };

  programs.niri.settings = {
    spawn-at-startup = [
      { argv = [ "noctalia" ]; }
    ];

    input = {
      keyboard = {
        repeat-delay = 400;
        repeat-rate = 25;
        track-layout = "global";
      };

      touchpad = {
        tap = true;
        accel-profile = "flat";
        scroll-method = "two-finger";
        natural-scroll = true;
      };

      mouse = {
        accel-profile = "flat";
        middle-emulation = true;
      };

      warp-mouse-to-focus.enable = true;
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "100%";
      };
    };

    cursor = {
      theme = "Bibata-Modern-Ice";
      size = 28;
      hide-after-inactive-ms = 5000;
    };

    layout = {
      gaps = 7;
      center-focused-column = "never";

      preset-column-widths = [
        { proportion = 0.25; }
        { proportion = 0.5; }
        { proportion = 0.75; }
        { proportion = 0.99; }
      ];

      preset-window-heights = [
        { proportion = 0.25; }
        { proportion = 0.5; }
        { proportion = 0.75; }
        { proportion = 1.0; }
      ];

      default-column-width = { proportion = 0.99; };

      focus-ring = { enable = false; };

      border = {
        enable = true;
        width = 1.9;
        active = {
          gradient = {
            from = "#a6e3a1";
            to = "#74c7ec";
            angle = 45;
          };
        };
        inactive = {
          gradient = {
            from = "#363a4f";
            to = "#9399b2";
            angle = 45;
          };
        };
      };

      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#0007";
      };
    };

    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 8.0;
          top-right = 8.0;
          bottom-right = 8.0;
          bottom-left = 8.0;
        };
        clip-to-geometry = true;
      }

      {
        matches = [
          { app-id = "firefox$"; title = "^Picture-in-Picture$"; }
          { app-id = "firefox$"; title = "^Library$"; }
          { app-id = "mpv$"; }
          { app-id = "waypaper$"; }
        ];
        open-floating = true;
      }

      # noctalia v5 settings window (dev.noctalia.Noctalia) — float it at a
      # fixed size so the settings UI doesn't tile
      {
        matches = [ { app-id = "dev.noctalia.Noctalia$"; } ];
        open-floating = true;
        default-column-width = { fixed = 1080; };
        default-window-height = { fixed = 920; };
      }
    ];

    # lets noctalia notification actions / window activation work even when
    # the activation serial has expired (recommended by noctalia's niri docs)
    debug = {
      honor-xdg-activation-with-invalid-serial = true;
    };

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      "Mod+Shift+E".action.quit = [ ];

      # Run
      "Mod+Return" = {
        hotkey-overlay.title = "Open a Terminal: kitty";
        action.spawn = "kitty";
      };
      "Mod+R" = {
        hotkey-overlay.title = "Open the App Launcher: ";
        # noctalia's launcher via IPC (wofi was removed from the stack)
        action.spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ];
      };
      "Mod+W" = {
        hotkey-overlay.title = "Open a browser: firefox";
        action.spawn = "firefox";
      };
      "Mod+F" = {
        hotkey-overlay.title = "Open file browser: cosmic-files";
        action.spawn = "cosmic-files";
      };
      "Super+Alt+L" = {
        hotkey-overlay.title = "Lock the Screen: noctalia";
        # noctalia's built-in lock screen (WlSessionLock) via IPC
        action.spawn = [ "noctalia" "msg" "session" "lock" ];
      };

      # Volume keys (allow-when-locked so they work while the session is locked)
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn-sh = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn-sh = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn-sh = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };

      # Media keys via playerctl (MPRIS-enabled players)
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl play-pause";
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl stop";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl previous";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl next";
      };

      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
      };

      "Mod+E" = {
        repeat = false;
        action.toggle-overview = [ ];
      };
      "Mod+Q" = {
        repeat = false;
        action.close-window = [ ];
      };
      "Mod+Shift+Q" = {
        repeat = false;
        action.spawn-sh = "niri msg --json focused-window | jq '.pid' | xargs kill -9";
      };

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      "Mod+Shift+Left".action.move-column-left = [ ];
      "Mod+Shift+Down".action.move-window-down = [ ];
      "Mod+Shift+Up".action.move-window-up = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];
      "Mod+Shift+H".action.move-column-left = [ ];
      "Mod+Shift+J".action.move-window-down = [ ];
      "Mod+Shift+K".action.move-window-up = [ ];
      "Mod+Shift+L".action.move-column-right = [ ];

      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      # monitor-movement binds were commented out in the original KDL — omitted
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = [ ];
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = [ ];
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-down = [ ];
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-up = [ ];
      };

      "Mod+WheelScrollRight".action.focus-column-right = [ ];
      "Mod+WheelScrollLeft".action.focus-column-left = [ ];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

      "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+0".action.focus-workspace = 10;

      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;
      "Mod+Shift+0".action.move-column-to-workspace = 10;

      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      "Mod+Y".action.switch-preset-column-width = [ ];
      "Mod+Shift+Y".action.switch-preset-column-width-back = [ ];
      "Mod+Ctrl+Shift+I".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+I".action.reset-window-height = [ ];
      "Mod+N".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+M".action.maximize-window-to-edges = [ ];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];
      "Mod+O".action.toggle-window-floating = [ ];

      # niri-shot is a declarative writeShellApplication (see niri-shot.nix)
      "Mod+S".action.spawn = [ "niri-shot" "region" "clip" ];
      "Mod+Shift+S".action.spawn = [ "niri-shot" "full" "clip" ];
      "Mod+Alt+S".action.spawn = [ "niri-shot" "region" "file" ];
      "Mod+Shift+Alt+S".action.spawn = [ "niri-shot" "full" "file" ];

      "Mod+Alt+W".action.set-dynamic-cast-window = [ ];
      "Mod+Alt+M".action.set-dynamic-cast-monitor = [ ];
      "Mod+Alt+C".action.clear-dynamic-cast-target = [ ];
    };
  };
}
