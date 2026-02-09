{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "tag +terminal, class:(Alacritty|kitty|com.mitchellh.ghostty)"
    ];
  };
}
