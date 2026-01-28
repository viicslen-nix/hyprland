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
  home.packages = with pkgs; [
    gpu-screen-recorder
  ];

  # Configure Noctalia with Stylix theming
  programs.noctalia-shell = {
    enable = true;

    # Stylix-based Material 3 color scheme
    colors = with colors;
      lib.mkForce {
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
      bar = {
        capsuleOpacity = lib.mkDefault 0.5;
        backgroundOpacity = lib.mkDefault 0.3;
        widgets = {
          left = [
            {
              id = "Launcher";
              icon = "rocket";
              usePrimaryColor = true;
            }
            {
              id = "Workspace";
              characterCount = 2;
              colorizeIcons = false;
              emptyColor = "secondary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = true;
              groupedBorderOpacity = 1;
              hideUnoccupied = false;
              iconScale = 0.8;
              labelMode = "index";
              occupiedColor = "secondary";
              showApplications = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = true;
              hideMode = "hidden";
              maxWidth = 200;
              scrollingMode = "hover";
              showIcon = true;
              useFixedWidth = false;
            }
            {
              id = "plugin:screen-recorder";
            }
          ];
          center = [
            {
              id = "NotificationHistory";
              hideWhenZero = true;
              showUnreadBadge = true;
            }
            {
              id = "Clock";
              usePrimaryColor = true;
            }
            {
              id = "MediaMini";
              hideMode = "hidden";
              panelShowAlbumArt = true;
              panelShowVisualizer = true;
            }
          ];
          right = [
            {
              id = "SystemMonitor";
              showCpuTemp = false;
              showCpuUsage = true;
              showMemoryAsPercent = true;
              showMemoryUsage = true;
              usePrimaryColor = true;
            }
            {
              id = "Tray";
              colorizeIcons = true;
              pinned = [];
              blacklist = [];
            }
            {
              id = "plugin:mini-docker";
            }
            {
              id = "Volume";
            }
            {
              id = "plugin:privacy-indicator";
            }
            {
              id = "ControlCenter";
              useDistroLogo = true;
              enableColorization = true;
              colorizeDistroLogo = true;
              colorizeSystemIcon = "primary";
            }
          ];
        };
      };

      general = {
        lockScreenCountdownDuration = 5000;
      };

      ui = {
        panelBackgroundOpacity = lib.mkDefault 0.4;
      };

      location = {
        name = "Miami, FL";
        useFahrenheit = true;
        use12hourFormat = true;
        hideWeatherCityName = true;
      };

      wallpaper = {
        directory = "/home/neoscode/Pictures/Wallpapers";
        automationEnabled = true;
      };

      appLauncher = {
        enableClipboardHistory = true;
      };

      dock = {
        backgroundOpacity = lib.mkDefault 0.3;
      };

      sessionMenu = {
        largeButtonsStyle = true;
      };

      notifications = {
        backgroundOpacity = lib.mkDefault 0.7;
      };

      osd = {
        backgroundOpacity = lib.mkDefault 0.7;
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
