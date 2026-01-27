# Hyprland plugins configuration
# Additional compositor features and extensions
{
  lib,
  osConfig,
  ...
}: {
  imports =
    [
      # Active plugins
      ./hyprexpo.nix # Workspace expo/overview
    ]
    ++ lib.optional osConfig.modules.desktop.hyprland.hyprsplit.enable ./hyprsplit.nix; # Advanced window splitting - may conflict with dwindle layout

  # Temporarily disabled plugins (uncomment when needed):
  # imports = [
  #   ./hyprspace.nix   # 3D workspace overview - requires good GPU performance
  #   ./hyprchroma.nix  # Color management - experimental, API may change
  # ];
}
