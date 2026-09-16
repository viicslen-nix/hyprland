inputs: {
  lib,
  pkgs,
  config,
  options,
  ...
}:
with lib; let
  name = "hyprland";
  namespace = "desktop";

  cfg = config.modules.${namespace}.${name};

  homeManagerLoaded = builtins.hasAttr "home-manager" options;
  stylixCursorSizeSet =
    builtins.hasAttr "stylix" config
    && builtins.hasAttr "cursor" config.stylix
    && builtins.hasAttr "size" config.stylix.cursor;

  portalBackends = {
    gtk = {
      portal = "gtk";
      package = pkgs.xdg-desktop-portal-gtk;
    };
    gnome = {
      portal = "gnome";
      package = pkgs.xdg-desktop-portal-gnome;
    };
    qt = {
      # The KDE backend ships kde.portal, so "qt" is not a valid portal name.
      portal = "kde";
      package = pkgs.kdePackages.xdg-desktop-portal-kde;
    };
  };
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnableOption "hyprland";

    terminal = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default terminal emulator to use for hyprland keybinds.
        If null, will use the defaults module terminal if available.
      '';
    };

    browser = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default browser to use for hyprland keybinds.
        If null, will use the defaults module browser if available.
      '';
    };

    editor = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default editor to use for hyprland keybinds.
        If null, will use the defaults module editor if available.
      '';
    };

    fileManager = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default file manager to use for hyprland keybinds.
        If null, will use the defaults module fileManager if available.
      '';
    };

    passwordManager = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default password manager to use for hyprland keybinds.
        If null, will use the defaults module passwordManager if available.
      '';
    };

    portals = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable XDG desktop portals";
      };

      backend = mkOption {
        type = types.enum ["gtk" "gnome" "qt"];
        default = "gtk";
        description = ''
          Primary portal backend to use for file choosers and URI handling.
          - gtk: Lightweight GTK file picker (recommended for visual continuity)
          - gnome: Full GNOME integration with additional features
          - qt: KDE/Qt file picker (for Qt-based setups)
        '';
      };

      xdgOpenUsePortal = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use portals for xdg-open (fixes FHS environments)";
      };

      extraBackends = mkOption {
        type = types.listOf (types.enum ["gtk" "gnome" "qt"]);
        default = [];
        example = ["gnome"];
        description = "Additional portal backends to install";
      };
    };

    hyprVariables = mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = {};
      description = "Hyprland-specific environment variables";
    };

    globalVariables = mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = {};
      description = "Global environment variables for Wayland/Hyprland";
    };

    hyprsplit.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable per-monitor workspaces through the hyprsplit Lua library and its keybinds";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.desktop.hyprland = {
        hyprVariables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XCURSOR_SIZE = mkIf stylixCursorSizeSet (builtins.toString config.stylix.cursor.size);
        };

        globalVariables = {
          XDG_SESSION_TYPE = "wayland";
          CLUTTER_BACKEND = "wayland";
          GDK_BACKEND = "wayland,x11";
          SDL_VIDEODRIVER = "wayland";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
        };
      };
    }

    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
        package = inputs.hyprland-git.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland-git.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        adwaita-fonts
        adwaita-qt6
        adwaita-qt
      ];

      services.gnome.gnome-keyring.enable = true;
    }

    (mkIf (cfg.portals.backend == "gnome") {
      programs.seahorse.enable = true;

      services.gnome = {
        gnome-remote-desktop.enable = true;
        gnome-settings-daemon.enable = true;
      };
    })

    (mkIf cfg.portals.enable {
      xdg.portal = {
        inherit (cfg.portals) xdgOpenUsePortal;
        config.hyprland.default = ["hyprland" portalBackends.${cfg.portals.backend}.portal];
        extraPortals = unique (map (backend: portalBackends.${backend}.package) ([cfg.portals.backend] ++ cfg.portals.extraBackends));
      };
    })

    (optionalAttrs homeManagerLoaded {
      home-manager.sharedModules = [
        {
          _module.args.wlLib = inputs.viicslen-lib.lib.wayland {inherit pkgs lib;};
          _module.args.hlLib = {
            bind = keys: dsp: opts: {_args = [keys (lib.generators.mkLuaInline dsp)] ++ lib.optional (opts != {}) opts;};
            exec = cmd: "hl.dsp.exec_cmd(${lib.generators.toLua {} cmd})";
          };
          imports = [
            ./config
            ./components
          ];

          wayland.windowManager.hyprland = {
            enable = true;
            package = null;
            portalPackage = null;
            systemd.enable = false;
            configType = "lua";
          };

          # Keep forced off: stylix's hyprland target enables it, and the unit would also start under niri.
          services.hyprpaper.enable = mkForce false;

          # Not extraLuaFiles: home-manager writes a nested store path there as literal text.
          xdg.configFile."hypr/hyprsplit/init.lua" = mkIf cfg.hyprsplit.enable {
            source = "${inputs.hyprsplit}/init.lua";
          };

          xdg.desktopEntries."org.gnome.Settings" = mkIf (cfg.portals.backend == "gnome") {
            name = "Settings";
            comment = "Gnome Control Center";
            icon = "org.gnome.Settings";
            exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
            categories = ["X-Preferences"];
            terminal = false;
          };

          dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":";
        }
      ];
    })
  ]);
}
