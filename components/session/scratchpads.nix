{
  pkgs,
  config,
  osConfig,
  lib,
  wlLib,
  hlLib,
  ...
}: let
  inherit (hlLib) bind exec;

  hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";

  webapp = name: url: (lib.concatStringsSep " " [
    "${lib.getExe pkgs.chromium}"
    "--user-data-dir=${config.xdg.configHome}/chromium/webapps/${name}"
    "--profile-directory=${name}"
    "--class=webapp-${name}"
    "--app=${url}"
  ]);

  pads = {
    term = {
      class = "kitty-dropterm";
      cmd = "kitty --class kitty-dropterm";
      size = "monitor_w*0.75 monitor_h*0.6";
    };
    volume = {
      class = "com.saivert.pwvucontrol";
      cmd = lib.getExe pkgs.pwvucontrol;
      size = "monitor_w*0.4 monitor_h*0.9";
    };
    bluetooth = {
      class = "io.github.kaii_lb.Overskride";
      cmd = lib.getExe pkgs.overskride;
      size = "monitor_w*0.4 monitor_h*0.9";
    };
    services = {
      class = "ferdium";
      cmd = "${pkgs.ferdium}/bin/ferdium";
      size = "monitor_w*0.6 monitor_h*0.9";
    };
    notes = {
      class = "obsidian";
      cmd = lib.getExe pkgs.obsidian;
      size = "monitor_w*0.4 monitor_h*0.9";
    };
    messages = {
      class = "chrome-messages.google.com__web_u_2_conversations-messages";
      cmd = webapp "messages" "https://messages.google.com/web/u/2/conversations";
      size = "monitor_w*0.4 monitor_h*0.9";
    };
    whatsapp = {
      class = "chrome-web.whatsapp.com__-whatsapp";
      cmd = webapp "whatsapp" "https://web.whatsapp.com";
      size = "monitor_w*0.5 monitor_h*0.9";
    };
    gemini = {
      class = "chrome-gemini.google.com__-gemini";
      cmd = webapp "gemini" "https://gemini.google.com";
      size = "monitor_w*0.5 monitor_h*0.9";
    };
  };

  menuEntry = key: desc: name: {
    inherit key desc;
    cmd = "${hyprctl} eval ${lib.escapeShellArg ''scratchpad("${name}")''}";
  };
in {
  wayland.windowManager.hyprland = {
    extraLuaFiles.scratchpads = ''
      local pads = ${lib.generators.toLua {} (lib.mapAttrs (_: p: {inherit (p) class cmd;}) pads)}

      function scratchpad(name)
        local pad = pads[name]
        if #hl.get_windows({ class = pad.class }) == 0 then
          hl.exec_cmd(pad.cmd)
        else
          hl.dispatch(hl.dsp.workspace.toggle_special(name))
        end
      end

      function minimize(float)
        local w = hl.get_active_window()
        if not w then
          return
        end
        if w.workspace.special then
          -- Keep follow unset: a non-silent move off a special workspace closes it and focuses the window.
          hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace() }))
        else
          if float then
            hl.dispatch(hl.dsp.window.float({ action = "enable" }))
          end
          hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
        end
      end
    '';

    settings = {
      window_rule =
        lib.mapAttrsToList (name: p: {
          match.class = "^(${p.class})$";
          # Don't add "silent": a window mapped silently never takes focus.
          workspace = "special:${name}";
          float = true;
          center = true;
          inherit (p) size;
        })
        pads;

      bind = [
        (bind "SUPER + X" "function() minimize(false) end" {})
        (bind "SUPER + SHIFT + X" "function() minimize(true) end" {})
        (bind "SUPER + CTRL + X" ''hl.dsp.workspace.toggle_special("minimized")'' {})
        (bind "SUPER + CTRL + T" ''function() scratchpad("term") end'' {})
        (bind "SUPER + CTRL + V" ''function() scratchpad("volume") end'' {})
        (bind "SUPER + S" (exec (wlLib.mkMenu [
          (menuEntry "b" "Bluetooth" "bluetooth")
          (menuEntry "s" "Services" "services")
          (menuEntry "n" "Notes" "notes")
          (menuEntry "m" "Messages" "messages")
          (menuEntry "w" "WhatsApp" "whatsapp")
          (menuEntry "g" "Gemini" "gemini")
        ])) {})
      ];
    };
  };
}
