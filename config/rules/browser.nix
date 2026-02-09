{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Browser types
      "tag +chromium-based-browser, class:([cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable)"
      "tag +firefox-based-browser, class:([fF]irefox|zen|librewolf)"

      # Force chromium-based browsers into a tile to deal with --app bug
      "tile, tag:chromium-based-browser"

      # Only a subtle opacity change, but not for video sites
      "opacity 1 0.97, tag:chromium-based-browser"
      "opacity 1 0.97, tag:firefox-based-browser"

      # Some video sites should never have opacity applied to them
      "opacity 1.0 1.0, initialTitle:((?i)(?:[a-z0-9-]+\.)*youtube\.com_/|app\.zoom\.us_/wc/home)"
    ];
  };
}
