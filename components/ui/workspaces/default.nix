{hlLib, ...}: let
  inherit (hlLib) bind;
in {
  wayland.windowManager.hyprland = {
    settings.bind = [
      (bind "SUPER + D" ''hl.dsp.submap("hyprflows")'' {})
    ];

    submaps.hyprflows = {
      onDispatch = "reset";
      settings.bind = [
        (bind "1" ''
          function()
            for _, app in ipairs({ { "zen-beta", 1 }, { "legcord", 11 }, { "kitty", 11 }, { "code", 12 }, { "kitty", 12 } }) do
              hl.exec_cmd(app[1], { workspace = app[2] .. " silent" })
            end
          end'' {})
        (bind "escape" ''hl.dsp.submap("reset")'' {})
        (bind "catchall" ''hl.dsp.submap("reset")'' {})
      ];
    };
  };
}
