{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  home.file.".config/flameshot/flameshot.ini".text = with config.lib.stylix.colors; ''
    [General]
    allowMultipleGuiInstances=true
    autoCloseIdleDaemon=true
    contrastOpacity=188
    copyPathAfterSave=true
    disabledTrayIcon=true
    drawColor=#ff0000
    savePathFixed=true
    showDesktopNotification=false
    showStartupLaunchMessage=false
    contrastUiColor=#${base0A}
    uiColor=#${base00}
  '';

  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class (flameshot), match:title (flameshot), pin on"
      "match:class (flameshot), match:title (flameshot), fullscreen_state 3 3"
      "match:class (flameshot), match:title (flameshot), float on"
    ];
    bind = let
      flameshot = pkgs.flameshot.override {enableWlrSupport = true;};
    in [
      "$mod SHIFT ALT, S, exec, ${getExe flameshot} gui"
    ];
  };
}
