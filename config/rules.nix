{...}: {
  imports = [
    ./rules/system.nix
    ./rules/jetbrains.nix
    ./rules/one-password.nix
  ];

  wayland.windowManager.hyprland.settings = {
    workspace = [
      # smart gaps
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];

    windowrule = [
      # Smart Gaps
      "match:float 0, match:workspace w[tv1], border_size 0"
      "match:float 0, match:workspace w[tv1], rounding 0"
      "match:float 0, match:workspace f[1], border_size 0"
      "match:float 0, match:workspace f[1], rounding 0"

      # Fix xwayland apps
      "match:xwayland 1, rounding 0"

      # Disable shadows when only one window is present
      "match:workspace w[t1], no_shadow on"

      # Throw sharing indicators away
      "match:title ^(.*is sharing (your screen|a window)\\.)$, workspace special silent"

      # Idle inhibit while watching videos
      "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
      # Keep the YouTube rule last: the later matching idle_inhibit wins.
      "match:class ^(firefox|microsoft-edge)$, idle_inhibit fullscreen"
      "match:class ^(firefox|microsoft-edge)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"

      # Make PiP windows stay on top
      "match:title ^(Picture-in-Picture)$, float on"
      "match:title ^(Picture-in-Picture)$, pin on"

      # Transparency
      "match:class ^(org.gnome.Nautilus|legcord|discord|code|libreoffice-calc)$, opacity 0.90 0.90"

      # GCR Prompter
      "match:class ^(gcr-prompter)$, dim_around on"

      # GTK File Chooser
      "match:class ^(xdg-desktop-portal-gtk)$, float on"
      "match:class ^(xdg-desktop-portal-gtk)$, center on"
      "match:class ^(xdg-desktop-portal-gtk)$, dim_around on"
      "match:class ^(xdg-desktop-portal-gtk)$, max_size monitor_w*0.8 monitor_h*0.8"

      # Satty
      "match:class ^(com\\.gabm\\.satty)$, float on"
      "match:class ^(com\\.gabm\\.satty)$, fullscreen on"

      # Flameshot's capture overlay has no class: keep these title-only
      "match:title ^(flameshot)$, float on"
      "match:title ^(flameshot)$, pin on"
      "match:title ^(flameshot)$, fullscreen_state 3 3"

      # Ferdium
      "match:class ^(ferdium)$, no_screen_share on"

      # LibreOffice
      "match:class ^(soffice)$, match:title ^(Text Import -)(.*)$, float on"
    ];
  };
}
