{
  pkgs,
  config,
  lib,
  ...
}: let
  noctalia = cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  # Stylix color integration
  inherit (config.lib.stylix) colors;
in {
  # Configure Noctalia with Stylix theming
  programs.noctalia-shell = {
    enable = true;

    # Stylix-based Material 3 color scheme
    colors = with colors; {
      mPrimary = "#${base0D}";
      mOnPrimary = "#${base00}";
      mSecondary = "#${base0E}";
      mOnSecondary = "#${base00}";
      mTertiary = "#${base0C}";
      mOnTertiary = "#${base00}";
      mSurface = "#${base00}";
      mOnSurface = "#${base05}";
      mSurfaceVariant = "#${base01}";
      mOnSurfaceVariant = "#${base04}";
      mError = "#${base08}";
      mOnError = "#${base00}";
      mOutline = "#${base03}";
      mShadow = "#${base00}";
      mHover = "#${base02}";
      mOnHover = "#${base05}";
    };

    # Noctalia settings - migrating waybar features
    settings = {
      # Bar configuration (replaces waybar)
      bar = {
        position = "top";
        density = "default";
        showCapsule = true;
        backgroundOpacity = 0.3; # Match waybar transparency
        floating = false;
        marginVertical = 0;
        marginHorizontal = 0;
        exclusive = true;

        widgets = {
          left = [
            {id = "Launcher";}
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "index";
            }
            {id = "ActiveWindow";}
          ];

          center = [
            {
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];

          right = [
            {id = "Tray";}
            {id = "SystemMonitor";} # Replaces waybar CPU/memory modules
            {id = "Network";}
            {id = "Bluetooth";}
            {id = "Volume";}
            {id = "Brightness";}
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {id = "NotificationHistory";}
            {id = "ControlCenter";}
          ];
        };
      };

      # General settings
      general = {
        radiusRatio = 0.2;
        enableShadows = true;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
      };

      # Location settings (replaces waybar clock timezone)
      location = {
        name = "Local";
        use12hourFormat = false;
        weatherEnabled = true;
      };

      # Control center configuration
      controlCenter = {
        position = "close_to_bar_button";
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = true;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
      };

      # Notifications (replaces waybar custom/notification)
      notifications = {
        enabled = true;
        location = "top_right";
        backgroundOpacity = 1;
        normalUrgencyDuration = 8;
      };

      # Audio settings (replaces waybar wireplumber)
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        volumeFeedback = false;
      };

      # Brightness settings (replaces waybar backlight)
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
      };

      # System monitor (replaces waybar cpu/memory)
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
      };

      # Disable wallpaper management (keep hyprpaper)
      wallpaper = {
        enabled = false;
      };

      # App launcher settings
      appLauncher = {
        position = "center";
        sortByMostUsed = true;
        showCategories = true;
      };

      # Session menu (replaces waybar custom/exit)
      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
      };
    };
  };

  # Hyprland integration
  wayland.windowManager.hyprland.settings = {
    # Layer rules for noctalia (replaces waybar layer rules)
    layerrule = [
      "blur, ^(noctalia)$"
      "blurpopups, ^(noctalia)$"
      "ignorealpha 0.2, ^(noctalia)$"
    ];

    # Keybinds for noctalia (replaces waybar keybinds)
    bind = [
      # Launcher
      "$mod, Space, exec, ${lib.concatStringsSep " " (noctalia "launcher toggle")}"

      # Control center
      "$mod, A, exec, ${lib.concatStringsSep " " (noctalia "controlCenter toggle")}"

      # Session menu (replaces wlogout)
      "$mod SHIFT, E, exec, ${lib.concatStringsSep " " (noctalia "sessionMenu toggle")}"

      # Notifications
      "$mod, N, exec, ${lib.concatStringsSep " " (noctalia "notificationHistory toggle")}"

      # Lock screen
      "$mod, L, exec, ${lib.concatStringsSep " " (noctalia "lockScreen lock")}"

      # Volume controls
      ", XF86AudioRaiseVolume, exec, ${lib.concatStringsSep " " (noctalia "volume increase")}"
      ", XF86AudioLowerVolume, exec, ${lib.concatStringsSep " " (noctalia "volume decrease")}"
      ", XF86AudioMute, exec, ${lib.concatStringsSep " " (noctalia "volume muteOutput")}"

      # Brightness controls
      ", XF86MonBrightnessUp, exec, ${lib.concatStringsSep " " (noctalia "brightness increase")}"
      ", XF86MonBrightnessDown, exec, ${lib.concatStringsSep " " (noctalia "brightness decrease")}"
    ];
  };
}
