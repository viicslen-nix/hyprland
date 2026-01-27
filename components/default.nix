# Home Manager components for Hyprland desktop environment
# Organized into UI components, session management, and tools
{
  imports = [
    # Session management (wallpaper, lock screen, idle management)
    ./session/hyprpaper.nix
    ./session/hyprlock.nix
    ./session/hypridle.nix
    ./session/pyprland.nix

    # Screenshot and annotation tools
    ./tools/flameshot.nix
    ./tools/satty.nix
    ./tools/swayosd.nix

    # UI components (panels, launchers, notifications)
    ./ui/noctalia
    ./ui/workspaces

    # Alternative UI components (commented - using noctalia instead)
    # ./ui/waybar
    # ./ui/hyprpanel
    # ./ui/rofi
    # ./ui/swaync
    # ./ui/wlogout
  ];
}
