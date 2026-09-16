{...}: {
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      # JetBrains IDEs opacity
      {
        match.class = "^(.*jetbrains.*)$";
        opacity = "0.95 0.95";
      }

      # Fix splash screen showing in weird places and prevent annoying focus takeovers
      {
        match = {
          class = "^jetbrains-.+$";
          title = "^splash$";
        };
        tag = "+jetbrains-splash";
      }
      {
        match.tag = "jetbrains-splash";
        float = true;
        center = true;
        no_focus = true;
        no_dim = true;
      }

      # Center popups/find windows
      {
        match = {
          class = "^jetbrains-.+$";
          title = "^$";
        };
        tag = "+jetbrains";
      }
      {
        match.tag = "jetbrains";
        center = true;
        no_dim = true;
        min_size = ["monitor_w*0.5" "monitor_h*0.5"];
      }
    ];
  };
}
