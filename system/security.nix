# Security Configuration for Hyprland
# Includes polkit authentication agent, PAM services, and GNOME keyring integration
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  name = "hyprland";
  namespace = "desktop";
  cfg = config.modules.${namespace}.${name};
in {
  config = mkIf cfg.enable {
    # Polkit (PolicyKit) for privilege escalation
    # Required for system operations like mounting drives, managing network, etc.
    security = {
      polkit.enable = true;

      # GNOME keyring integration for password management
      # Enabled when using GNOME portal backend for better integration
      pam.services.gdm.enableGnomeKeyring = mkIf (cfg.portals.backend == "gnome") true;
    };
  };
}
