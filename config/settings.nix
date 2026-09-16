{
  lib,
  osConfig,
  ...
}:
with lib; let
  scrolling = osConfig.modules.desktop.hyprland.layout == "scrolling";
in {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];

    # Don't drop uwsm finalize: under uwsm Hyprland skips the env import and graphical-session.target never starts.
    on = [
      {
        _args = [
          "hyprland.start"
          (generators.mkLuaInline ''
            function()
              hl.exec_cmd("uwsm finalize")
              hl.exec_cmd("/run/wrappers/bin/gnome-keyring-daemon --start --components=secrets")
              hl.exec_cmd("systemctl --user start desktop-shell.target")
            end'')
        ];
      }
    ];

    animation = [
      {
        leaf = "border";
        enabled = true;
        speed = 2;
        bezier = "default";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 4;
        bezier = "default";
      }
      {
        leaf = "windows";
        enabled = true;
        speed = 3;
        bezier = "default";
        style = "popin 80%";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 2;
        bezier = "default";
        style =
          if scrolling
          then "slidevert"
          else "slide";
      }
    ];

    # The gestures.* tuning below does nothing without a gesture.
    gesture =
      if scrolling
      then [
        {
          fingers = 3;
          direction = "horizontal";
          action = "scroll_move";
        }
        {
          fingers = 3;
          direction = "vertical";
          action = "workspace";
        }
      ]
      else [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

    config = {
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;

        # Window management
        allow_tearing = true;
        resize_on_border = true;
        extend_border_grab_area = 20;
        inherit (osConfig.modules.desktop.hyprland) layout;
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
          offset = [0 2];
          render_power = 3;
          sharp = false;
          scale = 1.0;
        };
      };

      animations.enabled = true;

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
          tap_to_click = true;
          tap_and_drag = true;
          drag_lock = 0;
          middle_button_emulation = false;
        };
      };

      dwindle = {
        preserve_split = true;
      };

      # Set regardless of layout so a workspace_rule can switch a single workspace to scrolling.
      scrolling = {
        column_width = 0.95;
        explicit_column_widths = "0.3, 0.48, 0.65, 0.95";
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

      render = {
        direct_scanout = mkDefault 2;
        expand_undersized_textures = true;
        send_content_type = true;
      };

      cursor = {
        sync_gsettings_theme = true;
        inactive_timeout = 2;
        hide_on_key_press = true;
        hide_on_touch = true;

        no_warps = false;
        warp_on_change_workspace = 0;
        persistent_warps = false;

        zoom_factor = 1.0;
        zoom_rigid = false;
        zoom_disable_aa = false;

        no_break_fs_vrr = 2;
        min_refresh_rate = 24;

        enable_hyprcursor = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
    };
  };
}
