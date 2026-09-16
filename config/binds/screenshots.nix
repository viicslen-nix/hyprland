{
  osConfig,
  pkgs,
  lib,
  wlLib,
  ...
}: let
  inherit (wlLib) mkMenu;

  grim = lib.getExe pkgs.grim;
  hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
  jq = lib.getExe pkgs.jq;
  envCmd = lib.getExe' pkgs.coreutils "env";
  sleep = lib.getExe' pkgs.coreutils "sleep";
  wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  screenshotFile = "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png";
  focusedOutput = ''OUT=$(${hyprctl} -j monitors | ${jq} -r '.[] | select(.focused) | .name')'';

  mkShotScript = name: body:
    lib.getExe (pkgs.writeShellScriptBin name ''
      set -euo pipefail
      ${body}
    '');

  scopes = [
    {
      key = "a";
      desc = "All monitors";
      delay = true;
      setup = "";
      grimArgs = "";
    }
    {
      key = "m";
      desc = "Focused monitor";
      delay = true;
      setup = focusedOutput;
      grimArgs = ''-o "$OUT"'';
    }
    {
      key = "w";
      desc = "Active window";
      delay = true;
      setup = ''GEOM=$(${hyprctl} -j activewindow | ${jq} -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')'';
      grimArgs = ''-g "$GEOM"'';
    }
    {
      key = "r";
      desc = "Region";
      delay = false;
      setup = "GEOM=$(${lib.getExe pkgs.slurp})";
      grimArgs = ''-g "$GEOM"'';
    }
  ];
  scope = lib.listToAttrs (map (s: lib.nameValuePair s.key s) scopes);

  saveShot = s:
    mkShotScript "hypr-shot-save-${s.key}" ''
      ${s.setup}
      FILE=${screenshotFile}
      mkdir -p "$(dirname "$FILE")"
      ${grim} ${s.grimArgs} "$FILE"
      ${wlCopy} < "$FILE"
    '';

  clipShot = s:
    mkShotScript "hypr-shot-clip-${s.key}" ''
      ${s.setup}
      ${grim} ${s.grimArgs} - | ${wlCopy}
    '';

  # Keep the popup-closing delay here, not in the scripts: the direct binds reuse them.
  scopeMenu = shot:
    mkMenu (map (s: {
        inherit (s) key desc;
        cmd = lib.optionalString s.delay "${sleep} 0.8 && " + shot s;
      })
      scopes);

  # DISPLAY must be cleared, or flameshot captures through XWayland.
  flameshotGui = mkShotScript "hypr-shot-flameshot" ''
    ${sleep} 0.2
    exec ${envCmd} DISPLAY= QT_QPA_PLATFORM=wayland ${lib.getExe pkgs.flameshot} gui
  '';

  sattyEdit = mkShotScript "hypr-shot-satty" ''
    FILE=${screenshotFile}
    mkdir -p "$(dirname "$FILE")"
    ${focusedOutput}
    ${grim} -o "$OUT" - \
      | ${lib.getExe pkgs.satty} --filename - \
          --fullscreen \
          --initial-tool crop \
          --copy-command ${wlCopy} \
          --output-filename "$FILE"
  '';
in {
  wayland.windowManager.hyprland.settings.bind = [
    "$mod SHIFT, S, exec, ${mkMenu [
      {
        key = "s";
        desc = "Save and copy to clipboard";
        cmd = scopeMenu saveShot;
      }
      {
        key = "c";
        desc = "Clipboard only";
        cmd = scopeMenu clipShot;
      }
      {
        key = "f";
        desc = "Open with Flameshot";
        cmd = flameshotGui;
      }
      {
        key = "e";
        desc = "Capture and crop with Satty";
        cmd = sattyEdit;
      }
    ]}"
    "$mod CTRL, S, exec, ${saveShot scope.w}"
    "$mod CTRL SHIFT, S, exec, ${saveShot scope.m}"
  ];
}
