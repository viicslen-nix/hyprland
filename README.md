# Hyprland Desktop Environment Flake

A comprehensive NixOS flake providing a fully configured Hyprland desktop environment with modern Wayland tools and extensions.

## Overview

This flake provides a complete Hyprland desktop setup including:

- Hyprland compositor with plugins and extensions
- Status bars (Waybar, HyprPanel)
- Application launchers (Rofi)
- Notification system (SwayNC)
- Window management and workspace utilities
- Screenshot and screen capture tools
- Authentication and session management

## Features

- **Compositor**: Hyprland with UWSM support
- **Status Bar**: Waybar with custom styling and scripts
- **Notifications**: SwayNC notification daemon
- **Application Launcher**: Rofi with emoji picker and web search
- **Session Management**: Hypridle and Hyprlock
- **Wallpaper**: Hyprpaper with Waypaper GUI
- **Screenshots**: Flameshot, Grim, Slurp, and Satty
- **Workspace Management**: Custom workspace switching and window rules
- **Plugins**: Hyprexpo, Hyprspace, Hyprsplit, and Hyprchroma
- **Audio**: PulseAudio/PipeWire controls with pavucontrol and pwvucontrol

## Structure

```text
.
├── flake.nix              # Main flake definition with inputs
├── default.nix           # NixOS module implementation
├── config/                # Hyprland configuration
│   ├── default.nix       # Configuration module imports
│   ├── settings.nix      # General Hyprland settings
│   ├── rules.nix         # Window and workspace rules
│   ├── binds.nix         # Keybindings configuration
│   ├── env.nix          # Environment variables
│   └── plugins/          # Plugin configurations
├── components/           # Desktop component configurations
│   ├── default.nix      # Component imports
│   ├── waybar/          # Status bar configuration
│   ├── rofi/            # Application launcher
│   ├── swaync/          # Notifications
│   ├── workspaces/      # Workspace management
│   ├── wlogout/         # Logout menu
│   ├── hyprpanel/       # Alternative panel
│   └── *.nix           # Individual component configs
└── README.md            # This file
```

## Usage

### As a NixOS Module

Add this flake as an input to your system flake:

```nix
{
  inputs = {
    # ... other inputs
    hyprland-config.url = "path:./flakes/hyprland";
    hyprland-config.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, hyprland-config, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      modules = [
        hyprland-config.nixosModules.default
        {
          modules.desktop.hyprland.enable = true;
        }
      ];
    };
  };
}
```

### Configuration Options

The module provides several configuration options:

```nix
modules.desktop.hyprland = {
  enable = true;                    # Enable the Hyprland desktop
  gnomeCompatibility = false;       # Enable GNOME app compatibility
  package = <derivation>;           # Custom Hyprland package
  portalPackage = <derivation>;     # Custom portal package

  # Environment variables
  hyprVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    # ... more variables
  };

  globalVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    # ... Wayland variables
  };

  extraGlobalVariables = {
    # Custom environment variables
  };
};
```

## Components

### Waybar

- Custom CSS styling
- PipeWire audio controls
- Mullvad VPN status
- System information displays

### Rofi

- Application launcher
- Emoji picker
- Web search functionality
- Custom styling

### SwayNC

- Notification daemon
- Custom CSS styling
- Notification history

### Workspace Management

- Custom workspace switching
- Application-specific workspace rules
- Window management utilities

### Screenshot Tools

- **Flameshot**: Feature-rich screenshot tool
- **Grim/Slurp**: Wayland native screenshot utilities
- **Satty**: Image annotation tool
- **Grimblast**: Hyprland-contrib screenshot utility

## Plugins

The flake includes several Hyprland plugins:

- **Hyprexpo**: Overview/expose functionality
- **Hyprspace**: Workspace management
- **Hyprsplit**: Advanced window splitting
- **Hyprchroma**: Color management
- **CSGO Vulkan Fix**: Gaming compatibility

## Environment Variables

The module automatically sets up Wayland environment variables:

- `XDG_SESSION_TYPE=wayland`
- `GDK_BACKEND=wayland,x11`
- `QT_QPA_PLATFORM=wayland;xcb`
- `MOZ_ENABLE_WAYLAND=1`
- `NIXOS_OZONE_WL=1`

## Dependencies

The flake pulls from several upstream sources:

- **Hyprland**: Main compositor
- **Waybar**: Status bar
- **Pyprland**: Python utilities
- **Hyprland-contrib**: Additional tools
- **Hyprland-plugins**: Plugin ecosystem
- **HyprPanel**: Alternative panel
- Various utility packages

## Customization

### Adding Custom Keybindings

Edit `config/binds.nix` to add custom keybindings.

### Modifying Window Rules

Edit `config/rules.nix` to customize window behavior and workspace assignments.

### Styling Components

Each component has its own styling configuration:

- Waybar: `components/waybar/style.css`
- SwayNC: `components/swaync/style.css`
- Rofi: `components/rofi/*.rasi`

### Adding New Components

1. Create a new `.nix` file in `components/`
2. Add the import to `components/default.nix`
3. Configure the component using Home Manager modules

## GNOME Compatibility

Enable `gnomeCompatibility = true` for better integration with GNOME applications:

- Enables GNOME keyring
- Provides GNOME Control Center
- Sets up proper file picker integration

## Troubleshooting

### XDG Portal Issues

The module configures multiple XDG portals. If you experience issues with file dialogs or screen sharing, check the portal configuration.

### Audio Issues

Ensure PipeWire and WirePlumber are properly configured on your system.

### Screenshot Not Working

Verify that the screenshot tools have the necessary permissions and that you're using Wayland-compatible tools.

## Contributing

When modifying this flake:

1. Test changes on your system first
2. Ensure all imports are properly structured
3. Update this README if adding new features
4. Consider backward compatibility for existing configurations

## License

This configuration follows the same license as your NixOS configuration.
