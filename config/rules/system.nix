{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Floating windows
      "float on, match:tag floating-window"
      "center on, match:tag floating-window"
      "size 875 600, match:tag floating-window"

      "tag +floating-window, match:class (org.omarchy.bluetui|org.omarchy.impala|org.omarchy.wiremix|org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Omarchy|About|TUI.float|imv|mpv)"
      "tag +floating-window, match:class (xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus), match:title ^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[Cc]hoose.*)"
      "float on, match:class org.gnome.Calculator"

      # Fullscreen screensaver
      "fullscreen on, match:class org.omarchy.screensaver"
      "float on, match:class org.omarchy.screensaver"

      # No transparency on media windows
      "tag -default-opacity, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
      "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"

      # Popped window rounding
      "rounding 8, match:tag pop"

      # Prevent idle while open
      "idle_inhibit always, match:tag noidle"
    ];
  };
}
