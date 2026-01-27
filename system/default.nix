# System-level configuration for Hyprland
# Contains portal, security, and service configurations
{
  imports = [
    ./portals.nix
    ./security.nix
    ./services.nix
  ];
}
