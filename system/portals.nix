# XDG Desktop Portal Configuration for Hyprland
# Handles file pickers, screen sharing, and desktop integration
#
# Portal backends:
# - hyprland: Hyprland-specific features (screencasting, screenshots)
# - gtk: GTK file chooser and URI handling (lightweight, recommended for visual continuity)
# - gnome: Full GNOME integration with additional screensharing features (heavier)
# - qt: KDE/Qt file picker (alternative for Qt-based setups)
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

  # Determine which additional portal backends to include
  extraPortalPackages = with pkgs;
    [
      xdg-desktop-portal-gtk # Always include GTK for file chooser
    ]
    ++ optionals (cfg.portals.backend == "gnome") [
      xdg-desktop-portal-gnome # Add GNOME portal if selected
    ]
    ++ optionals (cfg.portals.backend == "qt") [
      kdePackages.xdg-desktop-portal-kde # Add KDE portal if selected
    ]
    ++ (map (backend:
      if backend == "gnome"
      then xdg-desktop-portal-gnome
      else if backend == "qt"
      then kdePackages.xdg-desktop-portal-kde
      else xdg-desktop-portal-gtk)
    cfg.portals.extraBackends);

  # Build the portal priority list for Hyprland
  hyprlandPortals = ["hyprland" cfg.portals.backend];

  # Build the portal priority list for common/fallback
  commonPortals = [cfg.portals.backend];
in {
  config = mkIf (cfg.enable && cfg.portals.enable) {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = cfg.portals.xdgOpenUsePortal;

      # Portal backend configuration
      # Defines the priority order for which portal implementation to use
      config = {
        # Hyprland-specific portal configuration
        hyprland.default = hyprlandPortals;

        # Fallback for other environments
        common.default = commonPortals;
      };

      # Install portal packages
      extraPortals =
        [cfg.portalPackage] # xdg-desktop-portal-hyprland
        ++ extraPortalPackages;

      # Config packages (required for portal.conf generation)
      configPackages =
        [cfg.portalPackage]
        ++ extraPortalPackages;
    };

    # Enable wlr portal backend (required for some applications)
    xdg.portal.wlr.enable = true;
  };
}
