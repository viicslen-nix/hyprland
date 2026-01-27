{
  lib,
  config,
  osConfig,
  ...
}:
with lib; let
  hyprConfig = osConfig.modules.desktop.hyprland;
in {
  home.sessionVariables = filterAttrs (n: v: v != null) hyprConfig.globalVariables;

  xdg.configFile = mkIf osConfig.programs.hyprland.withUWSM {
    "uwsm/env".text = concatMapAttrsStringSep "\n" (name: value: "export ${name}=${value}") (filterAttrs (n: v: v != null) hyprConfig.globalVariables);
    "uwsm/env-hyprland".text = concatMapAttrsStringSep "\n" (name: value: "export ${name}=${value}") (filterAttrs (n: v: v != null) hyprConfig.hyprVariables);
  };

  wayland.windowManager.hyprland.settings.env = concatLists [
    (mapAttrsToList (name: value: "${name},${value}") (filterAttrs (n: v: v != null) hyprConfig.globalVariables))
    (mapAttrsToList (name: value: "${name},${value}") (filterAttrs (n: v: v != null) hyprConfig.hyprVariables))
  ];
}
