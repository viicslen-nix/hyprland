{
  # Keep these binds in their own required file: a hyprsplit load error then stays out of hyprland.lua.
  wayland.windowManager.hyprland.extraLuaFiles.hyprsplit-binds = ''
    local hs = require("hyprsplit")

    for i = 1, 10 do
      hl.bind("SUPER + " .. i % 10, hs.dsp.focus({ workspace = i }))
      hl.bind("SUPER + SHIFT + " .. i % 10, hs.dsp.window.move({ workspace = i, follow = false }))
    end

    hl.bind("SUPER + G", hs.dsp.grab_rogue_windows())
  '';
}
