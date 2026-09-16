{pkgs, ...}: let
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, split:workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, split:movetoworkspacesilent, ${toString (x + 1)}"
      ]
    )
    10);
in {
  wayland.windowManager.hyprland = {
    # Keep this from nixpkgs: a plugin built against any other hyprland fails the plugin API hash check.
    plugins = [pkgs.hyprlandPlugins.hyprsplit];

    settings = {
      plugin.hyprsplit = {
        num_workspaces = 10;
        persistent_workspaces = false;
      };

      bind =
        [
          "$mod, G, split:grabroguewindows"
        ]
        ++ workspaces;
    };
  };
}
