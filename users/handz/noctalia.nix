{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/noctalia.nix
    ../../modules/home-manager/noctalia-theming.nix
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        screen-recorder = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 1;
    };
    pluginSettings = {
      screen-recorder = {
        directory = "";
        filenamePattern = "recording_yyyy-MM-dd_HH-mm-ss";
        frameRate =  "60";
        audioCodec = "opus";
        videoCodec = "h264";
        quality = "very_high";
        colorRange = "limited";
        showCursor = true;
        copyToClipboard = true;
        audioSource = "both";
        videoSource = "portal";
      };
    };

    settings = {
      settingsVersion = 0;
      general = {
        animationSpeed = 2.5;
        #showScreenCorners = true;
        forceBlackScreenCorners = true;
      };
      colorSchemes = {
        darkMode = true;
        useWallpaperColors = false;
        matugenSchemeType = "scheme-fruit-salad";
        predefinedScheme = "Eldritch";
      };
      templates = {
        gtk = true;
        qt = true;
        niri = true;
        alacritty = true;
        #code = true;
        discord = true;
        #helix = true;
        enableUserTemplates = false;
      };
      wallpaper = {
        enabled = true;
        overviewEnabled = true;
        recursiveSearch = true;
        wallhavenPurity = "010";
        wallhavenApiKey = "";
        wallhavenResolutionWidth = "2560";
        wallhavenResolutionHeight = "1440";
        wallhavenResolutionMode = "atleast";
      };
      bar = {
        #outerCorners = false;
        widgets = {
          left = [
            {
              id = "Clock";
              formatHorizontal = "HH:mm ddd, dd MMM yyyy";
              tooltipFormat = "";
            }
            {
              id = "SystemMonitor";
              compactMode = false;
              showCpuTemp = true;
              showCpuUsage = true;
              showLoadAverage = true;
              showGpuTemp = true;
              showDiskUsage = true;
              diskPath = "/";
              showMemoryUsage = true;
              showMemoryAsPercent = false;
              showNetworkStats = true;
              useMonospaceFont = true;
            }
            {
              id = "MediaMini";
              compactMode = true;
              hideMode = "hidden";
              maxWidth = 350;
              scrollingMode = "always";
              showVisualizer = true;
            }
          ];
         center = [
            {
              id = "Workspace";
              labelMode = "index+name";
              showApplications = true;
              unfocusedIconsOpacity = 0.6;
            }
          ];
          right = [
            {
              id = "Tray";
              blacklist = [];
              drawerEnabled= true;
              hidePassive = false;
              pinned = [];
            }
            {
              id = "plugin:screen-recorder";
            }
            {
              id = "KeepAwake";
            }
            {
              id = "Volume";
              displayMode = "alwaysShow";
            }
            {
              id = "NotificationHistory";
              hideWhenZero = false;
              showUnreadBadge = true;
            }
            {
              id = "VPN";
              displayMode = "onhover";
            }
          ];
        };
      };
      systemMonitor = {
        enableDgpuMonitoring = true;
      };
      dock = {
        enabled = false;
      };
      controlCenter = {
        cards = [
            {
              id = "profile-card";
              enabled = true;
            }
            {
              id = "shortcuts-card";
              enabled = true;
            }
        ];
        shortcuts = {
          left = [
            {
              id = "Network";
            }
          ];
          right = [
            {
              id = "WallpaperSelector";
            }
          ];
        };
      };
      appLauncher = {
        position = "bottom_center";
        showCategories = false;
        enableClipboardHistory = true;
        enableClipPreview = true;
        autoPasteClipboard= false;
        terminalCommand = "alacritty -e";
        viewMode = "list";
        useApp2Unit = true;
      };
      notifications = {
        enabled = true;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };
        sounds = {
          enabled = true;
          volume = 0.5;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          #separateSounds = true;
          #lowSoundFile = "";
          #normalSoundFile = "";
          #criticalSoundFile = "";
        };
      };
      osd = {
        enabled = true;
        autoHideMs = 2000;
        backgroundOpacity = 1;
        enabledTypes = [ 0 1 2 3 ];
        location = "top_right";
        overlayLayer = true;
      };
      audio = {
        cavaFrameRate = 10;
        #externalMixer = "pwvucontrol || pavucontrol";
        preferredPlayer = "";
        mprisBlacklist = [];
        visualizerType = "linear";
        volumeOverdrive = true;
        volumeStep = 5;
      };
      location = {
        #name = "";
        analogClockInCalendar = true;
        firstDayOfWeek = 1;
        hideWeatherCityName = true;
        hideWeatherTimezone = false;
        showWeekNumberInCalendar = true;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
      };
      screenRecorder = {
        audioCodec = "opus";
        audioSource = "both";
        colorRange = "limited";
        copyToClipboard = false;
        directory = "${config.home.homeDirectory}/Videos";
        frameRate = 60;
        quality = "very_high";
        showCursor = true;
        videoCodec = "h264";
        videoSource = "portal";
      };
    };
  };
}
