{lib, ...}: let
  regexList = list: "^(${lib.concatStringsSep "|" list})$";
in {
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
    in [
      "blur, ${regexList blurred}"
      "xray 1, ${regexList ["bar"]}"
      "blurpopups, ${regexList blurred}"
      "ignorealpha 0.5, ${regexList highopacity}"
      "ignorealpha 0.2, ${regexList lowopacity}"
    ];

    workspace = [
      # smart gaps
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];

    # # window rules
    # windowrule = let
    #   float = [
    #     "org.gnome.Calculator"
    #     "org.gnome.design.Palette"
    #     "pavucontrol"
    #     "pwvucontrol"
    #     "nm-connection-editor"
    #     "Color Picker"
    #     "xdg-desktop-portal"
    #     "xdg-desktop-portal-gnome"
    #     "de.haeckerfelix.Fragments"
    #     "com.github.Aylur.ags"
    #   ];
    # in ["float, ${regexList float}"];

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
      "match:workspace w[t1], noshadow on"

      # Throw sharing indicators away
      "match:title ^(.*is sharing (your screen|a window)\\.)$, workspace special silent"

      # Idle inhibit while watching videos
      "match:class ^(mpv|.+exe|celluloid)$, idleinhibit focus"
      "match:class ^(firefox|microsoft-edge)$, match:title ^(.*YouTube.*)$, idleinhibit focus"
      "match:class ^(firefox|microsoft-edge)$, match:fullscreen 1, idleinhibit on"

      # Make PiP windows stay on top
      "match:title ^(Picture-in-Picture)$, float on"
      "match:title ^(Picture-in-Picture)$, pin on"

      # Transparency
      "match:class ^(org.gnome.Nautilus|legcord|discord|code|libreoffice-calc)$, opacity 0.90 0.90"

      # GCR Prompter
      "match:class ^(gcr-prompter)$, dimaround on"

      # Polkit
      "match:class ^(polkit-gnome-authentication-agent-1)$, float on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, center on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, dimaround on"
      "match:class ^(polkit-gnome-authentication-agent-1)$, size 50% 50%"

      # GTK File Chooser
      "match:class ^(xdg-desktop-portal-gtk)$, float on"
      "match:class ^(xdg-desktop-portal-gtk)$, center on"
      "match:class ^(xdg-desktop-portal-gtk)$, dimaround on"
      "match:class ^(xdg-desktop-portal-gtk)$, size <80% <80%"

      # 1Password
      "match:title (1Password), float on"
      "match:title (1Password), center on"

      # JetBrains IDEs
      "match:class ^(.*jetbrains.*)$, match:title ^(win.*)$, size <90% <80%"
      "match:class ^(.*jetbrains.*)$, opacity 0.95 0.95"
      # "match:class ^(.*jetbrains.*)$, match:title ^(Confirm Exit|Open Project|win424|win201|splash)$, center on"

      # "match:class jetbrains-toolbox, match:float 0, noinitialfocus on"
      # "match:class (jetbrains-)(.*), match:float 0, noinitialfocus on"
      # "match:class (jetbrains-)(.*), match:title ^$, match:initialTitle ^$, match:float 0, noinitialfocus on"
      # "match:class (jetbrains-)(.*), match:initialTitle (.+), match:float 0, center on"
      # "match:class (jetbrains-)(.*), match:title ^$, match:initialTitle ^$, match:float 0, center on"
      # "match:class (jetbrains-) (.*), match:title ^win(.*), match:initialTitle win.*, match:float 0, noinitialfocus on"

      # # -- Fix odd behaviors in IntelliJ IDEs --
      # #! Fix focus issues when dialogs are opened or closed
      # # windowrule = windowdance on, match:class ^(jetbrains-.*)$, match:float 1
      # #! Fix splash screen showing in weird places and prevent annoying focus takeovers
      # "match:class ^(jetbrains-.*)$, match:title ^(splash)$, match:float 1, center on"
      # "match:class ^(jetbrains-.*)$, match:title ^(splash)$, match:float 1, nofocus on"
      # "match:class ^(jetbrains-.*)$, match:title ^(splash)$, match:float 1, noborder on"

      # #! Center popups/find windows
      # "match:class ^(jetbrains-.*)$, match:title ^( )$, match:float 1, center on"
      # #! Enabling this makes it impossible to provide input to any popup dialogue (search window, new file, etc.)
      # "match:class ^(jetbrains-.*)$, match:title ^( )$, match:float 1, stayfocused on"
      # "match:class ^(jetbrains-.*)$, match:title ^( )$, match:float 1, noborder on"
      # #! Disable window flicker when autocomplete or tooltips appear
      # "match:class ^(jetbrains-.*)$, match:title ^(win.*)$, match:float 1, noinitialfocus on"
      # # -- End of IntelliJ Rules --

      # Satty
      "match:class ^(com.gabm.satty)$, float on"
      "match:class ^(com.gabm.satty)$, pseudo on"
      "match:class ^(com.gabm.satty)$, size 90% 90%"

      # LibreOffice
      "match:class ^(soffice)$, match:title ^(Text Import -)(.*)$, float on"
    ];
  };
}
