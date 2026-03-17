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
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnableOption (mdDoc "hyprland");

    package = mkOption {
      type = types.package;
      default = pkgs.hyprland;
      description = "The hyprland package to use";
    };

    portalPackage = mkOption {
      type = types.package;
      default = pkgs.xdg-desktop-portal-hyprland;
      description = "The portal package to use";
    };

    # Portal configuration options
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

    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Nvidia-specific optimizations for Hyprland.
        This includes:
        - nvidia_anti_flicker in OpenGL settings
        - Optimized render settings for Nvidia GPUs
        - Hardware cursor buffer optimizations
      '';
    };

    hyprsplit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable hyprsplit plugin and keybinds";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.hyprlandPlugins.hyprsplit;
        description = "The hyprsplit package to use";
      };
    };
  };

  imports = [
    inputs.hyprland.nixosModules.default
    ./system/security.nix
    ./system/services.nix
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      modules.desktop.hyprland = {
        hyprVariables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XCURSOR_SIZE = mkIf stylixCursorSizeSet (builtins.toString config.stylix.cursor.size);
        };

        globalVariables = {
          # Allow unfree packages
          NIXPKGS_ALLOW_UNFREE = "1";

          # Wayland environment
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
      # Hyprland program configuration
      programs = {
        hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
          package = cfg.package;
          portalPackage = cfg.portalPackage;
        };

        hyprlock.enable = true;
      };

      # System environment configuration
      environment = {
        variables.XDG_RUNTIME_DIR = "/run/user/$UID";

        systemPackages = with pkgs; [
          # Polkit authentication agents
          hyprpolkitagent
          polkit_gnome

          # Audio control
          qpwgraph
          pavucontrol
          pwvucontrol
          wireplumber

          # Wallpaper management
          waypaper
          hyprpaper

          # Screenshot tools
          grim
          slurp
          flameshot
          inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
          satty

          # Clipboard management
          wl-clipboard
          cliphist

          # Wayland utilities
          inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.pyprland
          wl-screenrec
          wlr-randr
          wlroots
        ];
      };

      # Hyprland cachix binary cache
      nix.settings = {
        substituters = [
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    }

    # XDG Portal Configuration
    (mkIf cfg.portals.enable (let
      # Determine which additional portal backends to include
      extraPortalPackages = with pkgs;
        [
          xdg-desktop-portal-gtk # Always include GTK for file chooser
        ]
        ++ optionals (cfg.portals.backend == "gnome") [
          xdg-desktop-portal-gnome # Add GNOME portal if selected
        ]
        ++ optionals (cfg.portals.backend == "qt") [
          kdePackages.xdg-desktop-portal-kde # Add KDE portal if selected
        ]
        ++ (map (backend:
          if backend == "gnome"
          then xdg-desktop-portal-gnome
          else if backend == "qt"
          then kdePackages.xdg-desktop-portal-kde
          else xdg-desktop-portal-gtk)
        cfg.portals.extraBackends);

      # Build the portal priority list for Hyprland
      hyprlandPortals = ["hyprland" cfg.portals.backend];

      # Build the portal priority list for common/fallback
      commonPortals = [cfg.portals.backend];
    in {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = cfg.portals.xdgOpenUsePortal;

        # Portal backend configuration
        # Defines the priority order for which portal implementation to use
        config = {
          # Hyprland-specific portal configuration
          hyprland.default = hyprlandPortals;

          # Fallback for other environments
          common.default = commonPortals;
        };

        # Install portal packages
        extraPortals =
          [cfg.portalPackage] # xdg-desktop-portal-hyprland
          ++ extraPortalPackages;

        # Config packages (required for portal.conf generation)
        configPackages =
          [cfg.portalPackage]
          ++ extraPortalPackages;
      };

      # Enable wlr portal backend (required for some applications)
      xdg.portal.wlr.enable = true;
    }))

    # Home Manager integration
    (mkIf homeManagerLoaded {
      home-manager.sharedModules = [
        {
          _module.args.hyprlandInputs = inputs;
          _module.args.wlLib = inputs.viicslen-lib.lib.wayland {inherit pkgs lib;};
          imports = [
            inputs.hyprland.homeManagerModules.default
            inputs.noctalia.homeModules.default
            ./config
            ./components
          ];

          wayland.windowManager.hyprland = {
            enable = true;
            package = null;
            portalPackage = null;
            systemd.enable = false;
          };

          # Use hyprpolkitagent for GTK backend, otherwise use GNOME's
          services.hyprpolkitagent.enable = cfg.portals.backend != "gnome";

          # GNOME Settings integration when using GNOME backend
          xdg.desktopEntries."org.gnome.Settings" = mkIf (cfg.portals.backend == "gnome") {
            name = "Settings";
            comment = "Gnome Control Center";
            icon = "org.gnome.Settings";
            exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
            categories = ["X-Preferences"];
            terminal = false;
          };

          # dconf settings for window decorations
          dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":";
        }
      ];
    })
  ]);
}
