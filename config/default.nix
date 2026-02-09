# Hyprland configuration modules
# Core settings, keybinds, window and layer rules, environment, and plugins
{
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./rules.nix
    ./environment.nix
    ./plugins
  ];
}
