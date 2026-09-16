{...}: {
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      {
        match.class = "^(1[pP]assword)$";
        no_screen_share = true;
        tag = "+floating-window";
      }
    ];
  };
}
