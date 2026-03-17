{
  lib,
  pkgs,
  config,
  osConfig,
  wlLib,
  ...
}: {
  wayland.windowManager.hyprland = {
    settings = let
      # Get defaults if they exist
      terminal =
        if (config.modules.functionality.defaults.terminal or null) != null
        then lib.getExe config.modules.functionality.defaults.terminal
        else "kitty";
      browser =
        if (config.modules.functionality.defaults.browser or null) != null
        then lib.getExe config.modules.functionality.defaults.browser
        else "firefox";
      fileManager =
        if (config.modules.functionality.defaults.fileManager or null) != null
        then lib.getExe config.modules.functionality.defaults.fileManager
        else "nautilus";
      editor =
        if (config.modules.functionality.defaults.editor or null) != null
        then lib.getExe config.modules.functionality.defaults.editor
        else null;
      passwordManager =
        if (config.modules.functionality.defaults.passwordManager or null) != null
        then "${lib.getExe config.modules.functionality.defaults.passwordManager} --quick-access"
        else "1password --quick-access";

      mkMenu = wlLib.mkMenu;
    in {
      # modifier key
      "$mod" = "SUPER";

      # applications
      "$terminal" = terminal;
      "$browser" = browser;
      "$fileManager" = fileManager;
      "$passwordManager" = passwordManager;

      # mouse movements
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      # binds
      bind = let
        workspaces =
          if osConfig.modules.desktop.hyprland.hyprsplit.enable
          then []
          else
            builtins.concatLists (builtins.genList (
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
              10);
      in
        [
          # compositor commands
          "$mod, Q, killactive,"
          "$mod, F, fullscreen,"
          "$mod, G, togglegroup,"
          "$mod, R, togglesplit,"
          "$mod, T, togglefloating,"
          "$mod, P, pin,"
          "$mod ALT, ,resizeactive,"

          # cycle monitors
          "$mod SHIFT, Left, focusmonitor, l"
          "$mod SHIFT, Right, focusmonitor, r"
          "$mod SHIFT, H, focusmonitor, l"
          "$mod SHIFT, L, focusmonitor, r"

          # send focused workspace to left/right monitors
          "$mod SHIFT ALT, Left, movecurrentworkspacetomonitor, l"
          "$mod SHIFT ALT, Right, movecurrentworkspacetomonitor, r"
          "$mod SHIFT ALT, H, movecurrentworkspacetomonitor, l"
          "$mod SHIFT ALT, L, movecurrentworkspacetomonitor, r"

          # cycle workspaces
          "$mod, Left, workspace, m-1"
          "$mod, Right, workspace, m+1"
          "$mod CTRL, H, workspace, m-1"
          "$mod CTRL, L, workspace, m+1"

          # move focus
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"

          ("$mod, W, exec, "
            + mkMenu [
              {
                key = "h";
                desc = "Move focus left";
                cmd = "hyprctl dispatch movefocus l";
              }
              {
                key = "l";
                desc = "Move focus right";
                cmd = "hyprctl dispatch movefocus r";
              }
              {
                key = "k";
                desc = "Move focus up";
                cmd = "hyprctl dispatch movefocus u";
              }
              {
                key = "j";
                desc = "Move focus down";
                cmd = "hyprctl dispatch movefocus d";
              }
            ])

          ("$mod SHIFT, W, exec, "
            + mkMenu [
              {
                key = "h";
                desc = "Move window left";
                cmd = "hyprctl dispatch movewindow l";
              }
              {
                key = "l";
                desc = "Move window right";
                cmd = "hyprctl dispatch movewindow r";
              }
              {
                key = "k";
                desc = "Move window up";
                cmd = "hyprctl dispatch movewindow u";
              }
              {
                key = "j";
                desc = "Move window down";
                cmd = "hyprctl dispatch movewindow d";
              }
            ])

          ("$mod, Z, exec, "
            + mkMenu [
              {
                key = "h";
                desc = "Resize window left";
                cmd = "hyprctl dispatch resizeactive -40 0";
              }
              {
                key = "l";
                desc = "Resize window right";
                cmd = "hyprctl dispatch resizeactive 40 0";
              }
              {
                key = "k";
                desc = "Resize window up";
                cmd = "hyprctl dispatch resizeactive 0 -40";
              }
              {
                key = "j";
                desc = "Resize window down";
                cmd = "hyprctl dispatch resizeactive 0 40";
              }
            ])

          # minimize
          "$mod CTRL, M, togglespecialworkspace, minimized"
          "$mod, M, exec, pypr toggle_special minimized"

          # Scrachpads
          "$mod CTRL, T, exec, pypr toggle term"
          "$mod CTRL, V, exec, pypr toggle volume"

          # system
          "$mod CTRL, L, exec, loginctl lock-session"

          # screenshot
          "$mod SHIFT ALT, S, exec, grimblast --notify --cursor copysave screen"

          # applications
          "$mod, Return, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, E, exec, $fileManager"
          "CTRL SHIFT, Space, exec, $passwordManager"

          # submaps
          ("$mod, A, exec, "
            + mkMenu [
              {
                key = "p";
                desc = "Open PhpStorm";
                cmd = "phpstorm";
              }
              {
                key = "d";
                desc = "Open DataGrip";
                cmd = "datagrip";
              }
              {
                key = "w";
                desc = "Open WebStorm";
                cmd = "webstorm";
              }
              {
                key = "s";
                desc = "Open Slack";
                cmd = "slack";
              }
              {
                key = "l";
                desc = "Open Discord";
                cmd = "legcord";
              }
              {
                key = "f";
                desc = "Open Firefox";
                cmd = "firefox";
              }
              {
                key = "c";
                desc = "Open VSCode";
                cmd = "code";
              }
              {
                key = "e";
                desc = "Open Nautilus";
                cmd = "nautilus";
              }
              {
                key = "t";
                desc = "Open Terminal";
                cmd = "ghostty";
              }
            ])
        ]
        ++ workspaces;

      bindl = [
        # media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"

        # volume
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindle = [
        # volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"

        # backlight
        ", XF86MonBrightnessUp, exec, brillo -q -u 300000 -A 5"
        ", XF86MonBrightnessDown, exec, brillo -q -u 300000 -U 5"
      ];
    };
  };
}
