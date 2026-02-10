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

### Keybindings Reference

This configuration uses a unified keymap system designed for muscle memory across both window managers (Hyprland/Niri) and editors (Neovim/Nixvim). See the **Unified Keymap Philosophy** section below for details.

#### Modifier Key
- **Primary Modifier**: `SUPER` (Windows/Command key)

#### Navigation (Vim-Style HJKL)
All navigation follows vim conventions:
- **H** = Left
- **J** = Down
- **K** = Up
- **L** = Right

#### Modifier Layers
The configuration uses consistent modifier stacking:
- **Base (SUPER)**: Focus/navigate
- **+ SHIFT**: Move/transfer
- **+ CTRL**: Workspace level
- **+ SHIFT + ALT**: Cross-monitor operations

#### Core Keybinds

**Window Management**
| Keybind | Action |
|---------|--------|
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + T` | Toggle floating |
| `SUPER + P` | Pin window |
| `SUPER + G` | Toggle group |
| `SUPER + R` | Toggle split |

**Navigation**
| Keybind | Action |
|---------|--------|
| `SUPER + H/J/K/L` | Move focus left/down/up/right |
| `SUPER + CTRL + H/L` | Cycle workspace -1/+1 |
| `SUPER + SHIFT + H/L` | Focus monitor left/right |
| `SUPER + 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move window to workspace (silent) |

**Monitor & Workspace Management**
| Keybind | Action |
|---------|--------|
| `SUPER + SHIFT + ALT + H/L` | Move workspace to monitor left/right |
| `SUPER + SHIFT + Left/Right` | Focus monitor left/right (arrows) |
| `SUPER + Left/Right` | Cycle workspace (arrows) |

**Interactive Menus (using wlr-which-key)**
| Keybind | Menu | Actions |
|---------|------|---------|
| `SUPER + W` | Window Focus | `h/j/k/l` to move focus |
| `SUPER + SHIFT + W` | Window Move | `h/j/k/l` to move window |
| `SUPER + Z` | Window Resize | `h/j/k/l` to resize (±40px) |
| `SUPER + A` | Application Launcher | See applications section |

**Applications**
| Keybind | Action |
|---------|--------|
| `SUPER + Return` | Terminal |
| `SUPER + B` | Browser |
| `SUPER + E` | File Manager |
| `CTRL + SHIFT + Space` | Password Manager |

**Application Menu (`SUPER + A`)**
| Key | Application |
|-----|-------------|
| `p` | PhpStorm |
| `d` | DataGrip |
| `w` | WebStorm |
| `s` | Slack |
| `l` | Discord |
| `f` | Firefox |
| `c` | VSCode |
| `e` | Nautilus |
| `t` | Terminal (ghostty) |

**Special Features**
| Keybind | Action |
|---------|--------|
| `SUPER + M` | Toggle minimized (pypr) |
| `SUPER + CTRL + M` | Toggle special workspace |
| `SUPER + CTRL + T` | Toggle terminal scratchpad |
| `SUPER + CTRL + V` | Toggle volume scratchpad |
| `SUPER + CTRL + L` | Lock session |
| `SUPER + SHIFT + ALT + S` | Screenshot |

**Media & System**
| Keybind | Action |
|---------|--------|
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioPrev/Next` | Previous/Next track |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioRaiseVolume` | Volume +6% |
| `XF86AudioLowerVolume` | Volume -6% |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness -5% |

**Mouse Bindings**
| Keybind | Action |
|---------|--------|
| `SUPER + Left Click` | Move window |
| `SUPER + Right Click` | Resize window |
| `SUPER + ALT + Left Click` | Resize window |

### Unified Keymap Philosophy

This configuration implements a **cross-system keymap standardization** to reduce cognitive load and leverage muscle memory:

**Principles:**
1. **Vim-style navigation everywhere**: H/J/K/L for directional movement in WMs and editors
2. **Consistent modifiers**: Same modifier patterns across Hyprland and Niri
3. **Namespace-based menus**: Interactive menus (via wlr-which-key) for grouped actions
4. **Leader key harmony**: Editor leader key (`Space`) mirrors WM application menu (`SUPER+A`)
5. **Mnemonic keys**: `Q` for quit/close, `E` for explorer, `F` for fullscreen, etc.

**Cross-System Consistency:**
- **Close/Quit**: `SUPER+Q` (WM), `<leader>q` (Neovim)
- **Explorer/Files**: `SUPER+E` (file manager), `<leader>e` (file tree)
- **Focus Movement**: `SUPER+H/J/K/L` (WM windows), `CTRL+H/J/K/L` (Neovim splits)
- **Interactive Menus**: Both systems use menu/leader-based grouping for complex actions

See the Niri, Nixvim, and Neovim READMEs for their specific implementations of this unified philosophy.

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
