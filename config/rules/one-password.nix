{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "no_screen_share on, match:class ^(1[pP]assword)$"
      "tag +floating-window, match:class ^(1[pP]assword)$"
    ];
  };
}
