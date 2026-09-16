{...}: {
  imports = [
    ./rules/system.nix
    ./rules/jetbrains.nix
    ./rules/one-password.nix
  ];

  wayland.windowManager.hyprland.settings = {
    workspace_rule = [
      # smart gaps
      {
        workspace = "w[tv1]";
        gaps_out = 0;
        gaps_in = 0;
      }
      {
        workspace = "f[1]";
        gaps_out = 0;
        gaps_in = 0;
      }
    ];

    window_rule = [
      # Smart Gaps
      {
        match = {
          float = false;
          workspace = "w[tv1]";
        };
        border_size = 0;
        rounding = 0;
      }
      {
        match = {
          float = false;
          workspace = "f[1]";
        };
        border_size = 0;
        rounding = 0;
      }

      # Fix xwayland apps
      {
        match.xwayland = true;
        rounding = 0;
      }

      # Disable shadows when only one window is present
      {
        match.workspace = "w[t1]";
        no_shadow = true;
      }

      # Throw sharing indicators away
      {
        match.title = "^(.*is sharing (your screen|a window)\\.)$";
        workspace = "special silent";
      }

      # Idle inhibit while watching videos
      {
        match.class = "^(mpv|.+exe|celluloid)$";
        idle_inhibit = "focus";
      }
      # Keep the YouTube rule last: the later matching idle_inhibit wins.
      {
        match.class = "^(firefox|microsoft-edge)$";
        idle_inhibit = "fullscreen";
      }
      {
        match = {
          class = "^(firefox|microsoft-edge)$";
          title = "^(.*YouTube.*)$";
        };
        idle_inhibit = "focus";
      }

      # Make PiP windows stay on top
      {
        match.title = "^(Picture-in-Picture)$";
        float = true;
        pin = true;
      }

      # Transparency
      {
        match.class = "^(org.gnome.Nautilus|legcord|discord|code|libreoffice-calc)$";
        opacity = "0.90 0.90";
      }

      # GCR Prompter
      {
        match.class = "^(gcr-prompter)$";
        dim_around = true;
      }

      # GTK File Chooser
      {
        match.class = "^(xdg-desktop-portal-gtk)$";
        float = true;
        center = true;
        dim_around = true;
        max_size = ["monitor_w*0.8" "monitor_h*0.8"];
      }

      # Satty
      {
        match.class = "^(com\\.gabm\\.satty)$";
        float = true;
        fullscreen = true;
      }

      # Flameshot's capture overlay has no class: keep these title-only
      {
        match.title = "^(flameshot)$";
        float = true;
        pin = true;
        fullscreen_state = "3 3";
      }

      # Ferdium
      {
        match.class = "^(ferdium)$";
        no_screen_share = true;
      }

      # LibreOffice
      {
        match = {
          class = "^(soffice)$";
          title = "^(Text Import -)(.*)$";
        };
        float = true;
      }
    ];
  };
}
