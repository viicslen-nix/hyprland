{
  osConfig,
  config,
  lib,
  wlLib,
  hlLib,
  ...
}: let
  cfg = osConfig.modules.desktop.hyprland;
  inherit (wlLib) mkMenu;
  inherit (hlLib) bind exec;

  hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";

  app = name:
    lib.mapNullable lib.getExe (
      if cfg.${name} != null
      then cfg.${name}
      else config.modules.functionality.defaults.${name} or null
    );

  terminal = app "terminal";
  browser = app "browser";
  editor = app "editor";
  fileManager = app "fileManager";
  passwordManager = lib.mapNullable (exe: "${exe} --quick-access") (app "passwordManager");

  directionMenu = desc: dsp:
    mkMenu (map (dir: {
        inherit (dir) key;
        desc = "${desc} ${dir.name}";
        cmd = "${hyprctl} dispatch ${lib.escapeShellArg (dsp dir)}";
      }) [
        {
          key = "h";
          name = "left";
          x = -40;
          y = 0;
        }
        {
          key = "l";
          name = "right";
          x = 40;
          y = 0;
        }
        {
          key = "k";
          name = "up";
          x = 0;
          y = -40;
        }
        {
          key = "j";
          name = "down";
          x = 0;
          y = 40;
        }
      ]);

  launcher = mkMenu ([
      {
        key = "s";
        desc = "Ferdium";
        cmd = "ferdium";
      }
      {
        key = "l";
        desc = "Discord";
        cmd = "legcord";
      }
    ]
    ++ lib.filter (entry: entry.cmd != null) [
      {
        key = "e";
        desc = "File Manager";
        cmd = fileManager;
      }
      {
        key = "t";
        desc = "Terminal";
        cmd = terminal;
      }
      {
        key = "b";
        desc = "Browser";
        cmd = browser;
      }
      {
        key = "p";
        desc = "Password Manager";
        cmd = passwordManager;
      }
      {
        key = "n";
        desc = "Editor";
        cmd = editor;
      }
    ]);

  workspaces = lib.optionals (!cfg.hyprsplit.enable) (lib.concatMap (i: let
    key = toString (lib.mod i 10);
  in [
    (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${toString i} })" {})
    (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString i}, follow = false })" {})
  ]) (lib.range 1 10));
in {
  imports = [
    ./screenshots.nix
    ./screenrecording.nix
  ];

  wayland.windowManager.hyprland.settings.bind =
    [
      (bind "SUPER + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
      (bind "SUPER + mouse:273" "hl.dsp.window.resize()" {mouse = true;})
      (bind "SUPER + ALT + mouse:272" "hl.dsp.window.resize()" {mouse = true;})

      (bind "SUPER + Q" "hl.dsp.window.close()" {})
      (bind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'' {})
      (bind "SUPER + SHIFT + F" "hl.dsp.window.fullscreen()" {})
      (bind "SUPER + CTRL + space" "hl.dsp.group.toggle()" {})
      (bind "SUPER + R" ''hl.dsp.layout("togglesplit")'' {})
      (bind "SUPER + T" "hl.dsp.window.float()" {})
      (bind "SUPER + P" "hl.dsp.window.pin()" {})

      (bind "SUPER + H" ''hl.dsp.focus({ direction = "left" })'' {})
      (bind "SUPER + L" ''hl.dsp.focus({ direction = "right" })'' {})
      (bind "SUPER + K" ''hl.dsp.focus({ direction = "up" })'' {})
      (bind "SUPER + J" ''hl.dsp.focus({ direction = "down" })'' {})
      (bind "SUPER + Left" ''hl.dsp.focus({ direction = "left" })'' {})
      (bind "SUPER + Right" ''hl.dsp.focus({ direction = "right" })'' {})

      (bind "SUPER + Up" ''hl.dsp.focus({ workspace = "m-1" })'' {})
      (bind "SUPER + Down" ''hl.dsp.focus({ workspace = "m+1" })'' {})
      (bind "SUPER + CTRL + H" ''hl.dsp.focus({ workspace = "m-1" })'' {})
      (bind "SUPER + CTRL + L" ''hl.dsp.focus({ workspace = "m+1" })'' {})

      (bind "SUPER + SHIFT + Left" ''hl.dsp.focus({ monitor = "l" })'' {})
      (bind "SUPER + SHIFT + Right" ''hl.dsp.focus({ monitor = "r" })'' {})
      (bind "SUPER + SHIFT + H" ''hl.dsp.focus({ monitor = "l" })'' {})
      (bind "SUPER + SHIFT + L" ''hl.dsp.focus({ monitor = "r" })'' {})

      (bind "SUPER + SHIFT + ALT + Left" ''hl.dsp.workspace.move({ monitor = "l" })'' {})
      (bind "SUPER + SHIFT + ALT + Right" ''hl.dsp.workspace.move({ monitor = "r" })'' {})
      (bind "SUPER + SHIFT + ALT + H" ''hl.dsp.workspace.move({ monitor = "l" })'' {})
      (bind "SUPER + SHIFT + ALT + L" ''hl.dsp.workspace.move({ monitor = "r" })'' {})
      (bind "SUPER + SHIFT + ALT + K" ''hl.dsp.workspace.move({ monitor = "u" })'' {})
      (bind "SUPER + SHIFT + ALT + J" ''hl.dsp.workspace.move({ monitor = "d" })'' {})

      (bind "SUPER + Tab" "hl.dsp.window.cycle_next()" {})
      (bind "SUPER + SHIFT + Tab" "hl.dsp.window.cycle_next({ next = false })" {})

      (bind "SUPER + W" (exec (directionMenu "Move focus" (dir: ''hl.dsp.focus({ direction = "${dir.name}" })''))) {})
      (bind "SUPER + SHIFT + W" (exec (directionMenu "Move window" (dir: ''hl.dsp.window.move({ direction = "${dir.name}" })''))) {})
      (bind "SUPER + Z" (exec (directionMenu "Resize window" (dir: "hl.dsp.window.resize({ x = ${toString dir.x}, y = ${toString dir.y}, relative = true })"))) {})

      (bind "SUPER + A" (exec launcher) {})
    ]
    ++ lib.optional (terminal != null) (bind "SUPER + Return" (exec terminal) {})
    ++ lib.optional (browser != null) (bind "SUPER + B" (exec browser) {})
    ++ lib.optional (fileManager != null) (bind "SUPER + E" (exec fileManager) {})
    ++ lib.optional (passwordManager != null) (bind "CTRL + SHIFT + space" (exec passwordManager) {})
    ++ workspaces;
}
