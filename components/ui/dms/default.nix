{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = lib.mkAfter [
      "uwsm app -- dms run"
    ];

    bind = [
      "$mod CTRL SHIFT, R, exec, killall dms; uwsm app -- dms run"
      "$mod, space, exec, dms ipc call spotlight toggle"
      "$mod, V, exec, dms ipc call clipboard toggle"
      "$mod, comma, exec, dms ipc call settings focusOrToggle"
      "$mod, N, exec, dms ipc call notifications toggle"
      "$mod, Y, exec, dms ipc call dankdash wallpaper"
      "$mod, TAB, exec, dms ipc call hypr toggleOverview"
    ];

    windowrule = [
      "match:class ^(org.quickshell)$, float on"
    ];

    layerrule = [
      "blur on, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)"
      "blur on, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)"
      "ignore_alpha 0, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal)"
      "ignore_alpha 0, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher)"

      # Animations
      "noanim, ^(dms)$"
      "animation slide right, match:namespace dms:control-center"
      "animation slide top, match:namespace dms:workspace-overview"
    ];
  };
}
