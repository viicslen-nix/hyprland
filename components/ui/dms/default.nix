{...}: {
  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;                   # Systemd service for auto-start
      restartIfChanged = true;         # Auto-restart dms.service when dank-material-shell changes
    };

    enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    enableClipboard = true;            # Clipboard history manager
    enableVPN = true;                  # VPN management widget
    enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;      # Audio visualizer (cava)
    enableCalendarEvents = true;       # Calendar integration (khal)

    plugins = {
      emojiLauncher.enable = true;
      dockerManager.enable = true;
      screenshotToggle.enable = true;
      wallpaperShufflerPlugin.enable = true;
      linuxWallpaperEngine.enable = true;
    };
  };

  wayland.windowManager.hyprland.settings = {
    layerrule = [
      "noanim, ^(dms)$"
    ];

    bind = [
      "$mod, space, exec, dms ipc call spotlight toggle"
      "$mod, V, exec, dms ipc call clipboard toggle"
      "$mod, comma, exec, dms ipc call settings focusOrToggle"
      "$mod, N, exec, dms ipc call notifications toggle"
      "$mod, Y, exec, dms ipc call dankdash wallpaper"
      "$mod, TAB, exec, dms ipc call hypr toggleOverview"
    ];
  };
}
