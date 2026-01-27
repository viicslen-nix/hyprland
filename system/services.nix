# System Services Configuration for Hyprland
# Optional services for enhanced GNOME integration
{
  lib,
  config,
  ...
}:
with lib; let
  name = "hyprland";
  namespace = "desktop";
  cfg = config.modules.${namespace}.${name};
in {
  config = mkIf cfg.enable {
    # Enable dconf for GTK application settings
    programs.dconf.enable = true;

    # Enable seahorse (GNOME keyring GUI) when using GNOME backend
    programs.seahorse.enable = mkIf (cfg.portals.backend == "gnome") true;

    # GNOME services for enhanced integration (optional, only with GNOME backend)
    services.gnome = mkIf (cfg.portals.backend == "gnome") {
      gnome-keyring.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
    };
  };
}
