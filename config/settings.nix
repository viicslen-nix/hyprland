{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  # Check if Nvidia optimizations are enabled
  nvidiaEnabled = config.modules.desktop.hyprland.nvidia or false;
in {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      ",preferred,auto,1"
    ];

    exec-once = [
      "dbus-update-activation-environment --systemd --all"
      "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      "gnome-keyring-daemon --start --components=secrets"

      "killall -q 1password; sleep .5 && 1password --silent"
      "killall -q mullvad; sleep .5 && mullvad-gui --silent"
      "killall -q jetbrains-toolbox; sleep .5 && jetbrains-toolbox"

      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"

      "noctalia-shell"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;

      # Window management
      allow_tearing = true;
      resize_on_border = true;
      extend_border_grab_area = 20;
      layout = "dwindle";
      no_focus_fallback = false;
      hover_icon_on_border = true;

      # Window snapping feature
      snap = {
        enabled = true;
        window_gap = 10;
        monitor_gap = 10;
        border_overlap = false;
        respect_gaps = false;
      };
    };

    decoration = {
      rounding = 16;

      # Opacity controls for better visual hierarchy
      active_opacity = 1.0;
      inactive_opacity = 0.95;
      fullscreen_opacity = 1.0;

      dim_inactive = true;
      dim_strength = 0.1;

      blur = {
        enabled = true;
        brightness = 1.0;
        contrast = 1.0;
        noise = 0.01;

        vibrancy = 0.2;
        vibrancy_darkness = 0.5;

        passes = 4;
        size = 7;

        # Enhanced blur options
        new_optimizations = true;
        xray = false;
        special = true;

        popups = true;
        popups_ignorealpha = 0.2;
      };

      shadow = {
        enabled = true;
        range = 20;
        offset = "0 2";
        render_power = 3;
        ignore_window = true;
        sharp = false;
        scale = 1.0;
      };
    };

    animations = {
      enabled = true;
      animation = [
        "border, 1, 2, default"
        "fade, 1, 4, default"
        "windows, 1, 3, default, popin 80%"
        "workspaces, 1, 2, default, slide"
      ];
    };

    # Gestures for touchpad users
    gestures = {
      workspace_swipe_distance = 300;
      workspace_swipe_cancel_ratio = 0.5;
      workspace_swipe_create_new = true;
      workspace_swipe_direction_lock = true;
      workspace_swipe_direction_lock_threshold = 10;
      workspace_swipe_forever = false;
    };

    group = {
      # Group behavior
      auto_group = true;
      insert_after_current = true;
      focus_removed_window = true;
      drag_into_group = 1;
      merge_groups_on_drag = true;

      groupbar = {
        enabled = true;
        font_size = 16;
        gradients = false;
        height = 14;
        render_titles = true;
        scrolling = true;
      };
    };

    input = {
      kb_layout = "us";
      kb_options = "compose:rwin";

      # Keyboard settings
      repeat_rate = 25;
      repeat_delay = 600;
      numlock_by_default = false;

      # Mouse settings
      follow_mouse = 1;
      mouse_refocus = false;
      accel_profile = "flat";
      sensitivity = 0.0;
      natural_scroll = false;
      focus_on_close = 0;

      # Touchpad configuration
      touchpad = {
        natural_scroll = false;
        disable_while_typing = true;
        tap-to-click = true;
        tap-and-drag = true;
        drag_lock = 0;
        middle_button_emulation = false;
      };
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    # Keybind behavior
    binds = {
      scroll_event_delay = 300;
      workspace_back_and_forth = false;
      allow_workspace_cycles = false;
      workspace_center_on = 0;
      focus_preferred_method = 0;
      movefocus_cycles_fullscreen = true;
    };

    misc = {
      animate_mouse_windowdragging = false;
      initial_workspace_tracking = 1;
      anr_missed_pings = 5;
      vrr = mkDefault 3;

      # Branding
      disable_splash_rendering = false;
      force_default_wallpaper = -1;

      # Power management
      mouse_move_enables_dpms = false;
      key_press_enables_dpms = false;

      # Window swallowing feature
      enable_swallow = true;
      swallow_regex = "^(kitty|alacritty|foot|wezterm|konsole|gnome-terminal|ghostty)$";
      swallow_exception_regex = "^(wev)$";

      # Behavior improvements
      vfr = true;
      focus_on_activate = false;
      mouse_move_focuses_monitor = true;
      close_special_on_empty = true;
      middle_click_paste = true;
      render_unfocused_fps = 15;
    };

    xwayland = {
      enabled = true;
      force_zero_scaling = true;
      use_nearest_neighbor = true;
    };

    # Nvidia-specific optimizations (conditional)
    opengl = mkIf nvidiaEnabled {
      nvidia_anti_flicker = true;
    };

    render = mkMerge [
      {
        direct_scanout = mkDefault 2;
        expand_undersized_textures = true;
        send_content_type = true;
      }
      # Additional Nvidia-specific render settings
      (mkIf nvidiaEnabled {
        ctm_animation = 2; # Auto (disables on Nvidia)
        cm_fs_passthrough = 2; # HDR passthrough
      })
    ];

    # Advanced cursor features
    cursor = mkMerge [
      {
        # Cursor visibility and behavior
        sync_gsettings_theme = true;
        inactive_timeout = 0; # Never hide
        hide_on_key_press = false;
        hide_on_touch = true;

        # Cursor warping (advanced feature)
        no_warps = false; # Allow warping
        warp_on_change_workspace = 0; # 0=disabled, 1=enabled, 2=force
        persistent_warps = false;
        default_monitor = "";

        # Cursor zoom features (advanced feature)
        zoom_factor = 1.0; # 1.0 = no zoom
        zoom_rigid = false;
        zoom_disable_aa = false;

        # VRR and performance
        no_break_fs_vrr = 2; # Auto for gaming
        min_refresh_rate = 24;

        # Hyprcursor support
        enable_hyprcursor = true;
      }
      # Nvidia-specific cursor settings
      (mkIf nvidiaEnabled {
        no_hardware_cursors = mkDefault 2;
        use_cpu_buffer = mkDefault 2;
      })
      # Non-Nvidia cursor settings
      (mkIf (!nvidiaEnabled) {
        no_hardware_cursors = mkDefault 0;
        use_cpu_buffer = mkDefault 0;
      })
    ];

    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };
  };
}
