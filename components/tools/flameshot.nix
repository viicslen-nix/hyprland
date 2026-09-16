{
  lib,
  config,
  ...
}: {
  home.file.".config/flameshot/flameshot.ini" = lib.mkIf (config.lib ? stylix) {
    text = with config.lib.stylix.colors; ''
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
  };
}
