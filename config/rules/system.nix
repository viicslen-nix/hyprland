{...}: {
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      # Floating windows
      {
        match.tag = "floating-window";
        float = true;
        center = true;
        size = [875 600];
      }

      {
        match.class = "(org.omarchy.bluetui|org.omarchy.impala|org.omarchy.wiremix|org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|Omarchy|About|TUI.float|imv|mpv)";
        tag = "+floating-window";
      }
      {
        match = {
          class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)";
          title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[Cc]hoose.*)";
        };
        tag = "+floating-window";
      }
      {
        match.class = "org.gnome.Calculator";
        float = true;
      }

      # Fullscreen screensaver
      {
        match.class = "org.omarchy.screensaver";
        fullscreen = true;
        float = true;
      }

      # No transparency on media windows
      {
        match.class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$";
        tag = "-default-opacity";
        opacity = "1 1";
      }

      # Popped window rounding
      {
        match.tag = "pop";
        rounding = 8;
      }

      # Prevent idle while open
      {
        match.tag = "noidle";
        idle_inhibit = "always";
      }
    ];
  };
}
