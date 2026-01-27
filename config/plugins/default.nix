# Hyprland plugins configuration
# Additional compositor features and extensions
{
  imports = [
    # Active plugins
    ./hyprexpo.nix # Workspace expo/overview

    # Temporarily disabled plugins (uncomment when needed):
    # ./hyprsplit.nix   # Advanced window splitting - may conflict with dwindle layout
    # ./hyprspace.nix   # 3D workspace overview - requires good GPU performance
    # ./hyprchroma.nix  # Color management - experimental, API may change
  ];
}
