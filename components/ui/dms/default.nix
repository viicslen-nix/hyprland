{
  lib,
  osConfig,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf ((osConfig.modules.desktop.shell or "dms") == "dms") {
    bind = [
      "$mod CTRL SHIFT, R, exec, systemctl --user restart dms.service"
      "$mod, space, exec, dms ipc call spotlight toggle"
      "$mod, V, exec, dms ipc call clipboard toggle"
      "$mod, comma, exec, dms ipc call settings focusOrToggle"
      "$mod, N, exec, dms ipc call notifications toggle"
      "$mod SHIFT, N, exec, dms ipc call notepad toggle"
      "$mod, Y, exec, dms ipc call dash toggle wallpaper"
      "$mod CTRL, Tab, exec, dms ipc call hypr toggleOverview"
      "$mod CTRL SHIFT, L, exec, dms ipc call lock lock"
      "CTRL ALT, Delete, exec, dms ipc call processlist toggle"
    ];

    bindl = [
      ", XF86AudioPlay, exec, dms ipc call mpris playPause"
      ", XF86AudioPrev, exec, dms ipc call mpris previous"
      ", XF86AudioNext, exec, dms ipc call mpris next"
      ", XF86AudioMute, exec, dms ipc call audio mute"
      ", XF86AudioMicMute, exec, dms ipc call audio micmute"
    ];

    bindle = [
      ", XF86AudioRaiseVolume, exec, dms ipc call audio increment 3"
      ", XF86AudioLowerVolume, exec, dms ipc call audio decrement 3"
      ", XF86MonBrightnessUp, exec, dms ipc call brightness increment 5 \"\""
      ", XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5 \"\""
    ];

    windowrule = [
      "match:class ^(org.quickshell)$, float on"
    ];

    layerrule = [
      "blur on, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)"
      "blur on, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)"
      "ignore_alpha 0, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)"
      "ignore_alpha 0, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)"
      "animation slide right, match:namespace dms:control-center"
      "animation slide top, match:namespace dms:workspace-overview"
    ];
  };
}
