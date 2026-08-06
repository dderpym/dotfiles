{ config, lib, pkgs, ... }:

{
  # Noctalia desktop shell (bar, launcher, notifications, dock, wallpaper, lock).
  # v4 (Quickshell-based) reads ~/.config/noctalia/settings.json; the shell also
  # watches the config dir and hot-reloads on atomic replacement, so a
  # `home-manager switch` re-applies without restarting the shell.
  #
  # Declarative tradeoff: settings.json is a read-only store symlink, so UI
  # setting changes won't persist — edit this file instead. colors.json and
  # plugins.json are deliberately left shell-owned: the shell regenerates
  # colors.json from the selected scheme and writes plugin download state into
  # plugins.json; making either read-only would break those features.
  # Custom scheme: Catppuccin Mocha with a true red error color. The bundled
  # Catppuccin "red" (#f38ba8) reads pink on dark — it drives the battery's
  # low/critical state and the system-monitor critical color. Palette is
  # otherwise identical to the bundled Catppuccin; only dark mError changes.
  xdg.configFile."noctalia/colorschemes/Catppuccin-Traffic/Catppuccin-Traffic.json" = {
    text = builtins.toJSON {
      dark = {
        mPrimary = "#cba6f7";
        mOnPrimary = "#11111b";
        mSecondary = "#fab387";
        mOnSecondary = "#11111b";
        mTertiary = "#94e2d5";
        mOnTertiary = "#11111b";
        mError = "#ef4444"; # was #f38ba8 — reads pink on dark, not red
        mOnError = "#11111b";
        mSurface = "#1e1e2e";
        mOnSurface = "#cdd6f4";
        mSurfaceVariant = "#313244";
        mOnSurfaceVariant = "#a3b4eb";
        mOutline = "#4c4f69";
        mShadow = "#11111b";
        mHover = "#94e2d5";
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

  xdg.configFile."noctalia/settings.json" = {
    # Replace the shell-managed file (force = remove the existing regular file)
    force = true;
    text = builtins.toJSON {
      settingsVersion = 59;

      # --- APP LAUNCHER ---
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        density = "default";
        enableClipPreview = true;
        enableClipboardChips = true;
        # cliphist is already wired above; turn on history search in the launcher
        enableClipboardHistory = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        ignoreMouseInput = false;
        overviewLayer = false;
        pinnedApps = [];
        position = "center";
        screenshotAnnotationTool = "";
        showCategories = true;
        showIconBackground = false;
        sortByMostUsed = true;
        # kitty is the default terminal here (was alacritty, which isn't installed)
        terminalCommand = "kitty -e";
        viewMode = "list";
      };

      # --- AUDIO ---
      audio = {
        mprisBlacklist = [];
        preferredPlayer = "";
        spectrumFrameRate = 30;
        spectrumMirrored = true;
        visualizerType = "linear";
        volumeFeedback = false;
        volumeFeedbackSoundFile = "";
        volumeOverdrive = false;
        volumeStep = 5;
      };

      # --- BAR (edge-to-edge, grows out of the top of the screen) ---
      # "simple" type: bar spans the full edge, top corners are flat against
      # the screen, bottom corners inverted (outerCorners) — the "coming out
      # of the top" look. Margins only apply to the floating type, zeroed here.
      bar = {
        autoHideDelay = 500;
        autoShowDelay = 150;
        backgroundOpacity = 0.9;
        barType = "simple";
        capsuleColorKey = "none";
        capsuleOpacity = 0.9;
        contentPadding = 2;
        density = "default";
        displayMode = "always_visible";
        enableExclusionZoneInset = true;
        fontScale = 1;
        frameRadius = 16;
        frameThickness = 8;
        hideOnOverview = false;
        marginHorizontal = 0;
        marginVertical = 0;
        middleClickAction = "none";
        middleClickCommand = "";
        middleClickFollowMouse = false;
        monitors = [];
        mouseWheelAction = "none";
        mouseWheelWrap = true;
        outerCorners = true;
        position = "top";
        reverseScroll = false;
        rightClickAction = "controlCenter";
        rightClickCommand = "";
        rightClickFollowMouse = true;
        screenOverrides = [];
        showCapsule = true;
        showOnWorkspaceSwitch = true;
        showOutline = false;
        useSeparateOpacity = false;
        widgetSpacing = 6;
        widgets = {
          center = [
            {
              characterCount = 2;
              colorizeIcons = false;
              # "none" resolves to the muted mOnSurface — unselected pills stay
              # quiet while the focused one keeps the mauve pop
              emptyColor = "none";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              fontWeight = "bold";
              groupedBorderOpacity = 1;
              # only show pills for workspaces that actually have windows
              hideUnoccupied = true;
              iconScale = 0.8;
              id = "Workspace";
              labelMode = "index";
              occupiedColor = "none";
              pillSize = 0.6;
              showApplications = false;
              showApplicationsHover = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
            }
          ];
          # left: control-center owl + expandable window title / media
          left = [
            {
              # noctalia owl logo — opens the control center; sits far left
              # where the launcher used to be. Mauve to match the old rocket.
              colorizeDistroLogo = false;
              colorizeSystemIcon = "primary";
              colorizeSystemText = "none";
              customIconPath = "";
              enableColorization = true;
              icon = "noctalia";
              id = "ControlCenter";
              useDistroLogo = false;
            }
            {
              colorizeIcons = false;
              hideMode = "hidden";
              id = "ActiveWindow";
              # room to breathe — window titles get wide
              maxWidth = 320;
              scrollingMode = "hover";
              showIcon = true;
              showText = true;
              textColor = "none";
              useFixedWidth = false;
            }
            {
              compactMode = false;
              hideMode = "hidden";
              # collapse entirely when nothing is playing
              hideWhenIdle = true;
              id = "MediaMini";
              maxWidth = 300;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              textColor = "none";
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          # right: tray, volume, brightness, battery, sysinfo, clock, notifs
          right = [
            {
              blacklist = [];
              chevronColor = "none";
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              id = "Tray";
              pinned = [];
            }
            {
              displayMode = "onhover";
              # teal audio icon — a little pop
              iconColor = "tertiary";
              id = "Volume";
              middleClickCommand = "pwvucontrol || pavucontrol";
              textColor = "none";
            }
            {
              applyToAllMonitors = false;
              displayMode = "onhover";
              # peach brightness icon — a little pop
              iconColor = "secondary";
              id = "Brightness";
              textColor = "none";
            }
            {
              deviceNativePath = "__default__";
              displayMode = "graphic-clean";
              hideIfIdle = false;
              hideIfNotDetected = true;
              id = "Battery";
              showNoctaliaPerformance = false;
              showPowerProfiles = false;
            }
            {
              compactMode = true;
              diskPath = "/";
              iconColor = "none";
              id = "SystemMonitor";
              showCpuCores = false;
              showCpuFreq = false;
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskAvailable = false;
              showDiskUsage = false;
              showDiskUsageAsPercent = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
              showSwapUsage = false;
              textColor = "none";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              # minimal clock; full date in the tooltip
              clockColor = "none";
              customFont = "";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm - dd MM";
              id = "Clock";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
            }
            {
              hideWhenZero = false;
              hideWhenZeroUnread = false;
              iconColor = "none";
              id = "NotificationHistory";
              showUnreadBadge = true;
              unreadBadgeColor = "primary";
            }
          ];
        };
      };

      # --- BRIGHTNESS ---
      brightness = {
        backlightDeviceMappings = [];
        brightnessStep = 5;
        enableDdcSupport = false;
        enforceMinimum = true;
      };

      # --- CALENDAR ---
      calendar = {
        cards = [
          { enabled = true; id = "calendar-header-card"; }
          { enabled = true; id = "calendar-month-card"; }
          { enabled = true; id = "weather-card"; }
        ];
      };

      # --- COLOR SCHEMES ---
      colorSchemes = {
        darkMode = true;
        generationMethod = "tonal-spot";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        monitorForColors = "";
        # Custom Catppuccin scheme with a true-red error color (see the
        # colorschemes/ file above) — otherwise matches the catppuccin module
        # (mocha/blue) and the niri border gradient elsewhere in this config.
        predefinedScheme = "Catppuccin-Traffic";
        schedulingMode = "off";
        syncGsettings = true;
        useWallpaperColors = false;
      };

      # --- CONTROL CENTER ---
      controlCenter = {
        cards = [
          { enabled = true; id = "profile-card"; }
          { enabled = true; id = "shortcuts-card"; }
          { enabled = true; id = "audio-card"; }
          { enabled = false; id = "brightness-card"; }
          { enabled = true; id = "weather-card"; }
          { enabled = true; id = "media-sysmon-card"; }
        ];
        diskPath = "/";
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
      };

      # --- DESKTOP WIDGETS ---
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        gridSnapScale = false;
        monitorWidgets = [];
        overviewEnabled = true;
      };

      # --- DOCK ---
      dock = {
        animationSpeed = 1;
        backgroundOpacity = 0.9;
        colorizeIcons = false;
        deadOpacity = 0.6;
        displayMode = "auto_hide";
        dockType = "floating";
        # dock disabled — apps are launched from the launcher (Mod+R)
        enabled = false;
        floatingRatio = 1;
        groupApps = false;
        groupClickAction = "cycle";
        groupContextMenuMode = "extended";
        groupIndicatorStyle = "dots";
        # running-but-unfocused apps get a mauve indicator dot
        inactiveIndicators = true;
        indicatorColor = "primary";
        indicatorOpacity = 0.8;
        indicatorThickness = 3;
        launcherIcon = "";
        launcherIconColor = "none";
        launcherPosition = "end";
        launcherUseDistroLogo = false;
        monitors = [];
        onlySameOutput = true;
        pinnedApps = [
          "kitty.desktop"
          "firefox.desktop"
          "vesktop.desktop"
          "slack.desktop"
        ];
        pinnedStatic = false;
        position = "bottom";
        showDockIndicator = false;
        showLauncherIcon = false;
        sitOnFrame = false;
        size = 1;
      };

      # --- GENERAL ---
      general = {
        allowPanelsOnScreenWithoutBar = true;
        allowPasswordWithFprintd = false;
        animationDisabled = false;
        animationSpeed = 1;
        autoStartAuth = false;
        avatarImage = "/home/stoler/.face";
        boxRadiusRatio = 1;
        clockFormat = "hh\\nmm";
        clockStyle = "custom";
        compactLockScreen = false;
        dimmerOpacity = 0.2;
        enableBlurBehind = true;
        enableLockScreenCountdown = true;
        enableLockScreenMediaControls = false;
        enableShadows = true;
        forceBlackScreenCorners = false;
        iRadiusRatio = 1;
        keybinds = {
          keyDown = [ "Down" ];
          keyEnter = [ "Return" "Enter" ];
          keyEscape = [ "Esc" ];
          keyLeft = [ "Left" ];
          keyRemove = [ "Del" ];
          keyRight = [ "Right" ];
          keyUp = [ "Up" ];
        };
        language = "";
        lockOnSuspend = true;
        lockScreenAnimations = false;
        lockScreenBlur = 0;
        lockScreenCountdownDuration = 10000;
        lockScreenMonitors = [];
        lockScreenTint = 0;
        passwordChars = false;
        radiusRatio = 1;
        reverseScroll = false;
        scaleRatio = 1;
        screenRadiusRatio = 1;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        # declarative config: no changelog nag on every start
        showChangelogOnStartup = false;
        showHibernateOnLockScreen = false;
        showScreenCorners = false;
        showSessionButtonsOnLockScreen = true;
        smoothScrollEnabled = true;
        telemetryEnabled = false;
      };

      # --- HOOKS ---
      hooks = {
        colorGeneration = "";
        darkModeChange = "";
        enabled = false;
        performanceModeDisabled = "";
        performanceModeEnabled = "";
        screenLock = "";
        screenUnlock = "";
        session = "";
        startup = "";
        wallpaperChange = "";
      };

      # --- IDLE (disabled: hypridle owns idle/suspend in this setup) ---
      idle = {
        customCommands = "[]";
        enabled = false;
        fadeDuration = 5;
        lockCommand = "";
        lockTimeout = 660;
        resumeLockCommand = "";
        resumeScreenOffCommand = "";
        resumeSuspendCommand = "";
        screenOffCommand = "";
        screenOffTimeout = 600;
        suspendCommand = "";
        suspendTimeout = 1800;
      };

      # --- LOCATION / WEATHER ---
      location = {
        analogClockInCalendar = false;
        # IP geolocation via api.noctalia.dev (city-level; no GPS/geoclue
        # needed), refreshed every 30 min. The resolved city is written to
        # settings.json at runtime — that write fails silently against the
        # read-only store symlink, so the city just lives in memory and is
        # re-derived on every start. Set `name` below as an offline fallback
        # if you want one (geolocate wins when it succeeds).
        autoLocate = true;
        firstDayOfWeek = -1;
        hideWeatherCityName = false;
        hideWeatherTimezone = false;
        name = "";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
        weatherTaliaMascotAlways = false;
      };

      # --- NETWORK ---
      network = {
        bluetoothAutoConnect = true;
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        bluetoothRssiPollIntervalMs = 60000;
        bluetoothRssiPollingEnabled = false;
        disableDiscoverability = false;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
      };

      # --- NIGHT LIGHT ---
      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = false;
        forced = false;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        nightTemp = "4000";
      };

      # --- NOCTALIA PERFORMANCE ---
      noctaliaPerformance = {
        disableDesktopWidgets = true;
        disableWallpaper = true;
      };

      # --- NOTIFICATIONS ---
      notifications = {
        backgroundOpacity = 0.95;
        clearDismissed = true;
        criticalUrgencyDuration = 15;
        density = "default";
        enableBatteryToast = true;
        enableKeyboardLayoutToast = true;
        enableMarkdown = true;
        enableMediaToast = false;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          critical = true;
          low = true;
          normal = true;
        };
        sounds = {
          criticalSoundFile = "";
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
        };
      };

      # --- OSD ---
      osd = {
        autoHideMs = 2000;
        backgroundOpacity = 1;
        enabled = true;
        enabledTypes = [ 0 1 2 ];
        location = "top_right";
        monitors = [];
        overlayLayer = true;
      };

      # --- PLUGINS ---
      plugins = {
        autoUpdate = false;
        notifyUpdates = true;
      };

      # --- SESSION MENU ---
      sessionMenu = {
        countdownDuration = 10000;
        enableCountdown = true;
        largeButtonsLayout = "single-row";
        largeButtonsStyle = true;
        position = "center";
        powerOptions = [
          { action = "lock"; enabled = true; keybind = "1"; }
          { action = "suspend"; enabled = true; keybind = "2"; }
          { action = "hibernate"; enabled = true; keybind = "3"; }
          { action = "reboot"; enabled = true; keybind = "4"; }
          { action = "logout"; enabled = true; keybind = "5"; }
          { action = "shutdown"; enabled = true; keybind = "6"; }
          { action = "rebootToUefi"; enabled = true; keybind = "7"; }
        ];
        showHeader = true;
        showKeybinds = true;
      };

      # --- SYSTEM MONITOR (traffic-light thresholds) ---
      # warning → yellow, critical → red (matches the scheme's error red).
      # Normal state stays mauve: the gauge fill is hardcoded to mPrimary,
      # the same color as the workspace pill — no per-widget knob for it.
      systemMonitor = {
        batteryCriticalThreshold = 5;
        batteryWarningThreshold = 20;
        cpuCriticalThreshold = 90;
        cpuWarningThreshold = 80;
        criticalColor = "#ef4444";
        diskAvailCriticalThreshold = 10;
        diskAvailWarningThreshold = 20;
        diskCriticalThreshold = 90;
        diskWarningThreshold = 80;
        enableDgpuMonitoring = false;
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        gpuCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        memCriticalThreshold = 90;
        memWarningThreshold = 80;
        swapCriticalThreshold = 90;
        swapWarningThreshold = 80;
        tempCriticalThreshold = 90;
        tempWarningThreshold = 80;
        useCustomColors = true;
        warningColor = "#f9e2af";
      };

      # --- TEMPLATES ---
      templates = {
        activeTemplates = [];
        enableUserTheming = false;
      };

      # --- UI ---
      ui = {
        boxBorderEnabled = false;
        fontDefault = "Sans Serif";
        fontDefaultScale = 1;
        fontFixed = "monospace";
        fontFixedScale = 1;
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = true;
        scrollbarAlwaysVisible = true;
        settingsPanelMode = "attached";
        settingsPanelSideBarCardStyle = false;
        tooltipsEnabled = true;
        translucentWidgets = false;
      };

      # --- WALLPAPER ---
      wallpaper = {
        automationEnabled = false;
        directory = "/home/stoler/Pictures/Wallpapers";
        enableMultiMonitorDirectories = false;
        enabled = true;
        favorites = [];
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = false;
        linkLightAndDarkWallpapers = true;
        monitorDirectories = [];
        overviewBlur = 0.4;
        overviewEnabled = false;
        overviewTint = 0.6;
        panelPosition = "follow_bar";
        randomIntervalSec = 300;
        setWallpaperOnAllMonitors = true;
        showHiddenFiles = false;
        skipStartupTransition = false;
        # Catppuccin base — used as the solid-color fallback / fill
        solidColor = "#1e1e2e";
        sortOrder = "name";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        transitionType = [ "fade" "disc" "stripes" "wipe" "pixelate" "honeycomb" ];
        useOriginalImages = false;
        useSolidColor = false;
        useWallhaven = false;
        viewMode = "single";
        wallhavenApiKey = "";
        wallhavenCategories = "111";
        wallhavenOrder = "desc";
        wallhavenPurity = "100";
        wallhavenQuery = "";
        wallhavenRatios = "";
        wallhavenResolutionHeight = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenSorting = "relevance";
        wallpaperChangeMode = "random";
      };
    };
  };
}
