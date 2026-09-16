{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # JetBrains IDEs opacity
      "opacity 0.95 0.95, match:class ^(.*jetbrains.*)$"

      # Fix splash screen showing in weird places and prevent annoying focus takeovers
      "tag +jetbrains-splash, match:class ^jetbrains-.+$, match:title ^splash$"
      "float on, match:tag jetbrains-splash"
      "center on, match:tag jetbrains-splash"
      "no_focus on, match:tag jetbrains-splash"
      "no_dim on, match:tag jetbrains-splash"

      # Center popups/find windows
      "tag +jetbrains, match:class ^jetbrains-.+$, match:title ^$"
      "center on, match:tag jetbrains"
      "no_dim on, match:tag jetbrains"
      "min_size monitor_w*0.5 monitor_h*0.5, match:tag jetbrains"
    ];
  };
}
