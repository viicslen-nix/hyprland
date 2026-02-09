{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Float LocalSend and fzf file picker
      "float, class:(Share|localsend)"
      "center, class:(Share|localsend)"
    ];
  };
}
