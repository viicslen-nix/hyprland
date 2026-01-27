# Hyprland configuration modules
# Core settings, keybinds, window rules, environment, and plugins
{
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./environment.nix
    ./plugins
  ];
}
