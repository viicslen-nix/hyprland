{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Floating windows
      "float, tag:floating-window"
      "center, tag:floating-window"
      "size 800 600, tag:floating-window"

      "tag +floating-window, class:(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float)"
      "tag +floating-window, class:(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus), title:^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files)"

      # Fullscreen screensaver
      "fullscreen, class:Screensaver"

      # No transparency on media windows
      "opacity 1 1, class:^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
    ];
  };
}
