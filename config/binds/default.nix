{
  osConfig,
  config,
  lib,
  wlLib,
  ...
}: let
  cfg = osConfig.modules.desktop.hyprland;
  inherit (wlLib) mkMenu;

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

  directionMenu = desc: dispatcher: args:
    mkMenu (lib.zipListsWith (dir: arg: {
        inherit (dir) key;
        desc = "${desc} ${dir.name}";
        cmd = "${hyprctl} dispatch ${dispatcher} ${arg}";
      }) [
        {
          key = "h";
          name = "left";
        }
        {
          key = "l";
          name = "right";
        }
        {
          key = "k";
          name = "up";
        }
        {
          key = "j";
          name = "down";
        }
      ]
      args);

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

  workspaces = lib.optionals (!cfg.hyprsplit.enable) (builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
      ]
    )
    10));
in {
  imports = [
    ./screenshots.nix
    ./screenrecording.nix
  ];

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    bind =
      [
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 1"
        "$mod SHIFT, F, fullscreen, 0"
        "$mod CTRL, space, togglegroup,"
        "$mod, R, layoutmsg, togglesplit"
        "$mod, T, togglefloating,"
        "$mod, P, pin,"

        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"

        "$mod, Up, workspace, m-1"
        "$mod, Down, workspace, m+1"
        "$mod CTRL, H, workspace, m-1"
        "$mod CTRL, L, workspace, m+1"

        "$mod SHIFT, Left, focusmonitor, l"
        "$mod SHIFT, Right, focusmonitor, r"
        "$mod SHIFT, H, focusmonitor, l"
        "$mod SHIFT, L, focusmonitor, r"

        "$mod SHIFT ALT, Left, movecurrentworkspacetomonitor, l"
        "$mod SHIFT ALT, Right, movecurrentworkspacetomonitor, r"
        "$mod SHIFT ALT, H, movecurrentworkspacetomonitor, l"
        "$mod SHIFT ALT, L, movecurrentworkspacetomonitor, r"
        "$mod SHIFT ALT, K, movecurrentworkspacetomonitor, u"
        "$mod SHIFT ALT, J, movecurrentworkspacetomonitor, d"

        "$mod, Tab, cyclenext,"
        "$mod SHIFT, Tab, cyclenext, prev"

        "$mod, W, exec, ${directionMenu "Move focus" "movefocus" ["l" "r" "u" "d"]}"
        "$mod SHIFT, W, exec, ${directionMenu "Move window" "movewindow" ["l" "r" "u" "d"]}"
        "$mod, Z, exec, ${directionMenu "Resize window" "resizeactive" ["-40 0" "40 0" "0 -40" "0 40"]}"

        "$mod, A, exec, ${launcher}"
      ]
      ++ lib.optional (terminal != null) "$mod, Return, exec, ${terminal}"
      ++ lib.optional (browser != null) "$mod, B, exec, ${browser}"
      ++ lib.optional (fileManager != null) "$mod, E, exec, ${fileManager}"
      ++ lib.optional (passwordManager != null) "CTRL SHIFT, Space, exec, ${passwordManager}"
      ++ workspaces;
  };
}
