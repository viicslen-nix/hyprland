# Hyprland Desktop Environment Module

A comprehensive NixOS flake for configuring the Hyprland Wayland compositor with a complete desktop environment setup.

## Features

- **Hyprland Compositor**: Modern tiling Wayland compositor with animations and effects
- **Portal Integration**: Properly configured XDG desktop portals for file pickers, screen sharing, and desktop integration
- **Session Management**: Wallpaper (hyprpaper), screen locking (hyprlock), and idle management (hypridle)
- **UI Components**: Noctalia shell, Rofi launcher, SwayNC notifications, and more
- **Plugin System**: Extensible with Hyprland plugins (hyprexpo, hyprsplit, hyprspace, hyprchroma)
- **Screenshot Tools**: Integrated grimblast, satty, and flameshot
- **Visual Continuity**: GTK-first approach for consistent theming across applications

## Module Options

### Basic Configuration

```nix
modules.desktop.hyprland = {
  enable = true;                # Enable Hyprland desktop environment
  package = <derivation>;       # Hyprland package (default: from flake input)
  portalPackage = <derivation>; # Portal package (default: from flake input)
};
```

### Portal Configuration

The portal system handles file choosers, screen sharing, and other desktop integration features:

```nix
modules.desktop.hyprland.portals = {
  enable = true;                # Enable XDG desktop portals (default: true)

  backend = "gtk";              # Portal backend: "gtk" | "gnome" | "qt"
                                # - gtk: Lightweight, recommended for visual continuity
                                # - gnome: Full GNOME features (heavier)
                                # - qt: KDE/Qt integration

  xdgOpenUsePortal = true;      # Use portals for xdg-open (default: true)

  extraBackends = [ "gnome" ];  # Additional backends to install (default: [])
};
```

### Environment Variables

```nix
modules.desktop.hyprland = {
  # Hyprland-specific variables
  hyprVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XCURSOR_SIZE = "24";
  };

  # Global Wayland environment variables
  globalVariables = {
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = "1";
    
    # Add your own custom variables
    MY_CUSTOM_VAR = "value";

    # Remove default variables by setting them to null
    SDL_VIDEODRIVER = null;
  };
};
```

## Usage

### In your NixOS configuration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland-flake.url = "path:./flakes/hyprland";
  };

  outputs = {nixpkgs, hyprland-flake, ...}: {
    nixosConfigurations.yourHost = nixpkgs.lib.nixosSystem {
      modules = [
        hyprland-flake.nixosModules.default
        {
          modules.desktop.hyprland = {
            enable = true;
            portals.backend = "gtk";  # Use GTK portals for consistency
          };
        }
      ];
    };
  };
}
```

## Portal Backend Comparison

| Backend | Size   | Features                           | Use Case                    |
|---------|--------|------------------------------------|-----------------------------|
| **gtk** | Light  | File picker, URI handling          | Recommended for most setups |
| gnome   | Heavy  | + Screen sharing, GNOME integration| If you use GNOME apps       |
| qt      | Medium | KDE/Qt file picker                 | Qt-heavy environments       |

**Recommendation**: Use `gtk` for visual continuity and lightweight operation. Only use `gnome` if you specifically need GNOME screensharing or have GNOME-specific requirements.

## Available Components

### UI Components

- **Noctalia**: Modern status bar and shell (primary, replaces Waybar)
- **Rofi**: Application launcher with custom themes
- **SwayNC**: Notification daemon with customizable styles
- **Wlogout**: Logout/power menu
- **Workspaces**: Workspace indicators

### Session Management

- **Hyprpaper**: Wallpaper manager (integrates with Stylix)
- **Hyprlock**: Lock screen with customization
- **Hypridle**: Idle management with suspend/lock timeouts
- **Pyprland**: Scratchpads and window extensions

### Tools

- **Grimblast**: Screenshot utility (Hyprland-contrib)
- **Flameshot**: Feature-rich screenshot tool
- **Satty**: Screenshot annotation
- **SwayOSD**: On-screen display for volume/brightness

## Plugins

Hyprland plugins add extra compositor features:

- **hyprexpo**: Workspace overview/expo (active)
- **hyprsplit**: Advanced window splitting (disabled - may conflict with dwindle)
- **hyprspace**: 3D workspace overview (disabled - needs GPU performance)
- **hyprchroma**: Color management (disabled - experimental)

To enable a plugin, uncomment it in `config/plugins/default.nix`.

## Formatting

This flake uses Alejandra for consistent Nix formatting:

```bash
# Format all files in the flake
nix fmt

# Or manually with alejandra
nix run nixpkgs#alejandra -- .
```

## Binary Cache

The module automatically configures the official Hyprland binary cache for faster builds:

```nix
nix.settings = {
  substituters = [ "https://hyprland.cachix.org" ];
  trusted-public-keys = [ "hyprland.cachix.org-1:..." ];
};
```

## Dependencies

### Flake Inputs

- **nixpkgs**: NixOS package repository
- **hyprland**: Hyprland compositor
- **hyprland-contrib**: Additional tools (grimblast, etc.)
- **hyprland-plugins**: Official plugin collection
- **pyprland**: Python extensions for Hyprland
- **noctalia**: Noctalia shell UI
- **hypridle**, **hyprpaper**: Session management
- **hyprspace**, **hyprsplit**, **hyprchroma**: Optional plugins

### System Packages

Automatically installed when the module is enabled:

- Polkit authentication agents
- Audio control (pavucontrol, pwvucontrol)
- Clipboard management (wl-clipboard, cliphist)
- Screenshot tools (grim, slurp, grimblast)
- Wayland utilities (wlr-randr, wlroots)

## Customization

### Changing Keybinds

Edit `config/keybinds.nix` to customize keyboard shortcuts.

### Modifying Window Rules

Edit `config/window-rules.nix` for application-specific behaviors.

### Adjusting Visual Settings

Edit `config/settings.nix` for animations, blur, gaps, borders, etc.

### Adding Scratchpads

Edit `components/session/pyprland.nix` to add or modify scratchpad configurations.

## Troubleshooting

### Portal Issues

If file pickers or screen sharing don't work:

1. Check that `xdg.portal.enable = true` in your portal configuration
2. Verify the backend matches your DE preferences
3. Check `xdg-desktop-portal --version` and ensure services are running

### Environment Variables

Variables are set in multiple places:

- System-wide in `default.nix`
- UWSM integration in `config/environment.nix`
- Session variables in Home Manager

### Performance Issues

If animations are slow:

1. Reduce blur passes in `config/settings.nix`
2. Disable `dim_inactive` or reduce `dim_strength`
3. Consider disabling plugins like hyprspace

## Migration from Previous Setup

### Breaking Changes

- **Option renamed**: `gnomeCompatibility` → `portals.backend = "gnome"`
- **File moves**: Config files renamed for clarity (`binds.nix` → `keybinds.nix`, etc.)
- **Structure**: Components reorganized into `ui/`, `tools/`, `session/` subdirectories

### Update Your Configuration

Replace:

```nix
modules.desktop.hyprland.gnomeCompatibility = true;
```

With:

```nix
modules.desktop.hyprland.portals.backend = "gnome";
```

## Contributing

When adding new components or modifying existing ones:

1. Keep files organized in appropriate subdirectories
2. Document complex configurations with inline comments
3. Format code with Alejandra before committing
4. Update this README if adding new features

## License

This configuration is part of a personal NixOS setup. Feel free to use and adapt it for your own needs.
