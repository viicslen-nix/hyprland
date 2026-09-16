{
  osConfig,
  pkgs,
  lib,
  wlLib,
  hlLib,
  ...
}: let
  inherit (wlLib) mkRecordCmd mkMenu;
  inherit (hlLib) bind exec;

  hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
  jq = lib.getExe pkgs.jq;
in {
  wayland.windowManager.hyprland.settings.bind = [
    (bind "SUPER + SHIFT + R" (exec (mkMenu [
      {
        key = "q";
        desc = "Stop recording";
        cmd = "${lib.getExe' pkgs.procps "pkill"} -INT wl-screenrec";
      }
      {
        # wl-screenrec records one output at a time; with no -o/-g it bails on multi-monitor setups.
        key = "a";
        desc = "Focused monitor";
        cmd = mkRecordCmd ''-o "$(${hyprctl} -j monitors | ${jq} -r '.[] | select(.focused) | .name')"'';
      }
      {
        key = "m";
        desc = "Single monitor";
        cmd = mkRecordCmd ''-o "$(${hyprctl} -j monitors | ${jq} -r '.[].name' | ${lib.getExe pkgs.wofi} --dmenu)"'';
      }
      {
        key = "w";
        desc = "Active window";
        cmd = mkRecordCmd ''-g "$(${hyprctl} -j activewindow | ${jq} -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"'';
      }
      {
        key = "r";
        desc = "Region";
        cmd = mkRecordCmd ''-g "$(${lib.getExe pkgs.slurp})"'';
      }
    ])) {})
  ];
}
