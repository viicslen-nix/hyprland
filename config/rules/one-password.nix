{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "no_screen_share on, match:class ^(1[p|P]assword)$"
      "tag +floating-window, match:class ^(1[p|P]assword)$"
    ];
  };
}
