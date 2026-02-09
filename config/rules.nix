{lib, ...}: let
  regexList = list: "^(${lib.concatStringsSep "|" list})$";
in {
  import = [
    ./rules/one-password.nix
    ./rules/jetbrains.nix
    ./rules/browser.nix
    ./rules/localsend.nix
    ./rules/system.nix
    ./rules/terminal.nix
  ];

  wayland.windowManager.hyprland.settings = {
    # layer rules
    layerrule = let
      lowopacity = [
        "bar"
        "notifications"
        "osd"
        "logout_dialog"
      ];

      highopacity = [
        "calendar"
        "system-menu"
        "anyrun"
        "logout_dialog"
        "music"
      ];

      blurred = lib.concatLists [
        lowopacity
        highopacity
      ];
    in
      lib.mkForce [
        "match:namespace ${regexList blurred}, blur on"
        "match:namespace ${regexList blurred}, blur_popups on"
        "match:namespace ${regexList highopacity}, ignore_alpha 0.5"
        "match:namespace ${regexList lowopacity}, ignore_alpha 0.2"
      ];

    workspace = [
      # smart gaps
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];

    # window rules (v0.53.0 unified syntax)
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
      "match:class ^(firefox|microsoft-edge)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
      "match:class ^(firefox|microsoft-edge)$, match:fullscreen 1, idle_inhibit on"

      # Make PiP windows stay on top
      "match:title ^(Picture-in-Picture)$, float on"
      "match:title ^(Picture-in-Picture)$, pin on"

      # Transparency
      "match:class ^(org.gnome.Nautilus|legcord|discord|code|libreoffice-calc)$, opacity 0.90 0.90"

      # GCR Prompter
      "match:class ^(gcr-prompter)$, dim_around on"

      # Polkit
      "match:class ^(polkit-gnome-authentication-agent-1)$, float on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, center on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, dim_around on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, size 50% 50%"

      # GTK File Chooser
      "match:class ^(xdg-desktop-portal-gtk)$, float on"
      "match:class ^(xdg-desktop-portal-gtk)$, center on"
      "match:class ^(xdg-desktop-portal-gtk)$, dim_around on"
      "match:class ^(xdg-desktop-portal-gtk)$, size <80% <80%"

      # Satty
      "match:class ^(com.gabm.satty)$, float on"
      "match:class ^(com.gabm.satty)$, pseudo on"
      "match:class ^(com.gabm.satty)$, size 90% 90%"

      # LibreOffice
      "match:class ^(soffice)$, match:title ^(Text Import -)(.*)$, float on"
    ];
  };
}
