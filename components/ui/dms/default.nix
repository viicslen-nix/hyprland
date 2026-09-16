{
  lib,
  osConfig,
  hlLib,
  ...
}: let
  inherit (hlLib) bind exec;

  modals = "polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal";
  popouts = "bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|system-update|process-list-popout|battery|popout|app-launcher";
in {
  wayland.windowManager.hyprland = lib.mkIf ((osConfig.modules.desktop.shell or "dms") == "dms") {
    settings = {
      bind = [
        (bind "SUPER + CTRL + SHIFT + R" (exec "systemctl --user restart dms.service") {})
        (bind "SUPER + space" (exec "dms ipc call spotlight toggle") {})
        (bind "SUPER + V" (exec "dms ipc call clipboard toggle") {})
        (bind "SUPER + comma" (exec "dms ipc call settings focusOrToggle") {})
        (bind "SUPER + N" (exec "dms ipc call notifications toggle") {})
        (bind "SUPER + SHIFT + N" (exec "dms ipc call notepad toggle") {})
        (bind "SUPER + Y" (exec "dms ipc call dash toggle wallpaper") {})
        (bind "SUPER + CTRL + Tab" (exec "dms ipc call hypr toggleOverview") {})
        (bind "SUPER + CTRL + SHIFT + L" (exec "dms ipc call lock lock") {})
        (bind "SUPER + M" (exec "dms ipc call processlist focusOrToggle") {})
        (bind "CTRL + ALT + Delete" (exec "dms ipc call processlist toggle") {})

        (bind "XF86AudioPlay" (exec "dms ipc call mpris playPause") {locked = true;})
        (bind "XF86AudioPrev" (exec "dms ipc call mpris previous") {locked = true;})
        (bind "XF86AudioNext" (exec "dms ipc call mpris next") {locked = true;})
        (bind "XF86AudioMute" (exec "dms ipc call audio mute") {locked = true;})
        (bind "XF86AudioMicMute" (exec "dms ipc call audio micmute") {locked = true;})

        (bind "XF86AudioRaiseVolume" (exec "dms ipc call audio increment 3") {
          locked = true;
          repeating = true;
        })
        (bind "XF86AudioLowerVolume" (exec "dms ipc call audio decrement 3") {
          locked = true;
          repeating = true;
        })
        (bind "XF86MonBrightnessUp" (exec ''dms ipc call brightness increment 5 ""'') {
          locked = true;
          repeating = true;
        })
        (bind "XF86MonBrightnessDown" (exec ''dms ipc call brightness decrement 5 ""'') {
          locked = true;
          repeating = true;
        })
      ];

      window_rule = [
        {
          match.class = "^(org.quickshell)$";
          float = true;
        }
      ];

      layer_rule = [
        {
          match.namespace = "dms:(${modals})";
          blur = true;
          ignore_alpha = 0;
        }
        {
          match.namespace = "dms:(${popouts})";
          blur = true;
          ignore_alpha = 0;
        }
        {
          match.namespace = "dms:control-center";
          animation = "slide right";
        }
        {
          match.namespace = "dms:workspace-overview";
          animation = "slide top";
        }
      ];
    };

    # Don't add "binds": Hyprland fires every duplicate bind, and dms/binds.lua rebinds this flake's keys.
    extraConfig = lib.concatMapStrings (m: ''
      if package.searchpath("dms.${m}", package.path) then require("dms.${m}") end
    '') ["colors" "outputs" "layout" "cursor" "windowrules"];
  };
}
