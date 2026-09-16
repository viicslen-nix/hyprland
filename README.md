# Hyprland

NixOS module for a Hyprland session started through UWSM, with
DankMaterialShell (DMS) as the shell. Every package comes from nixpkgs
(Hyprland 0.56 series, hyprlang config); the only inputs are `nixpkgs` and
`viicslen-lib`. Why it is built this way is in [CONTEXT.md](./CONTEXT.md).

```nix
imports = [inputs.hyprland.nixosModules.default];
modules.desktop.hyprland.enable = true;
```

Settings, binds and rules are applied through `home-manager.sharedModules`, so
they need home-manager loaded.

## Options

All under `modules.desktop.hyprland`:

```nix
{
  enable = true;        # programs.hyprland (UWSM, XWayland), gnome-keyring, Adwaita themes

  # Packages the binds launch. null falls back to home-manager's
  # modules.functionality.defaults.<name>; with neither, the bind and its
  # Mod+A entry are left out. The password manager runs with --quick-access.
  terminal = null;
  browser = null;
  editor = null;
  fileManager = null;
  passwordManager = null;

  portals = {
    enable = true;
    backend = "gtk";     # "gtk" | "gnome" | "qt"; paired with the hyprland portal
    extraBackends = [];  # further backends to install
    xdgOpenUsePortal = true;
  };

  hyprVariables = {};    # defaults: XDG_CURRENT_DESKTOP, XDG_SESSION_DESKTOP, XCURSOR_SIZE (Stylix)
  globalVariables = {};  # defaults: Wayland hints (GDK_BACKEND, QT_QPA_PLATFORM, NIXOS_OZONE_WL, ...)

  hyprsplit.enable = true;  # per-monitor workspaces
}
```

`portals.backend = "gnome"` also enables seahorse, gnome-settings-daemon,
gnome-remote-desktop and a Settings launcher.

Both variable sets become Hyprland `env =` lines and are written to UWSM's env
files, which UWSM sources before the compositor starts:
`~/.config/uwsm/env` (`globalVariables`) and `~/.config/uwsm/env-hyprland`
(`hyprVariables`). `globalVariables` also lands in `home.sessionVariables`.
Null values are skipped, so `lib.mkForce null` drops a default.

## Session

Hyprland's `exec-once` starts `gnome-keyring-daemon` (secrets),
`desktop-shell.target` and `pypr`. The target is declared by the root repo's
desktop shell module; the selected shell binds itself to it.

DMS supplies the polkit agent, idle and lock, wallpaper, clipboard history, OSD
and notifications. This flake adds only its binds, window rule and layer rules,
and only while `modules.desktop.shell` is `"dms"` (or unset).

## Structure

```text
.
├── flake.nix               # nixosModules.default, eval-only check
├── Justfile                # just check
├── default.nix             # options, programs.hyprland, portals, home-manager wiring
├── config/
│   ├── settings.nix        # compositor settings, exec-once
│   ├── environment.nix     # hyprVariables/globalVariables -> env, UWSM env files
│   ├── rules.nix           # workspace and window rules
│   ├── rules/              # system, jetbrains, one-password
│   ├── binds/
│   │   ├── default.nix     # core binds, Mod+W/Shift+W/Z/A menus, digits without hyprsplit
│   │   ├── screenshots.nix
│   │   └── screenrecording.nix
│   └── plugins/
│       ├── default.nix     # imports hyprsplit.nix when hyprsplit.enable
│       └── hyprsplit.nix
└── components/
    ├── session/pyprland.nix   # scratchpads, minimize
    ├── tools/flameshot.nix    # flameshot.ini, Stylix colours
    └── ui/
        ├── dms/default.nix    # DMS binds and layer rules
        └── workspaces/        # hyprflows submap, work.nix layout script
```

## Keybinds

`Mod` is Super. Hyprland fires every bind on a matching combo, so each combo
must exist in exactly one of the files below.

**`config/binds/default.nix`**

| Keys | Action |
|------|--------|
| `Mod+Q` | Close window |
| `Mod+F` | Maximize |
| `Mod+Shift+F` | Fullscreen |
| `Mod+T` | Toggle floating |
| `Mod+P` | Pin |
| `Mod+R` | Toggle dwindle split |
| `Mod+Ctrl+Space` | Toggle group |
| `Mod+H/J/K/L`, `Mod+Left/Right` | Focus left/down/up/right |
| `Mod+Tab`, `Mod+Shift+Tab` | Cycle to next/previous window |
| `Mod+Up/Down`, `Mod+Ctrl+H/L` | Previous/next workspace on this monitor |
| `Mod+1…0`, `Mod+Shift+1…0` | Workspace 1–10, move window there silently (without hyprsplit) |
| `Mod+Shift+H/L`, `Mod+Shift+Left/Right` | Focus monitor left/right |
| `Mod+Shift+Alt+H/J/K/L`, `Mod+Shift+Alt+Left/Right` | Move workspace to monitor |
| `Mod+W` | Menu: focus `h/j/k/l` |
| `Mod+Shift+W` | Menu: move window `h/j/k/l` |
| `Mod+Z` | Menu: resize by 40px `h/j/k/l` |
| `Mod+A` | Menu: `s` Ferdium, `l` Discord, `e` file manager, `t` terminal, `b` browser, `p` password manager, `n` editor |
| `Mod+Return` / `Mod+B` / `Mod+E` | Terminal / browser / file manager |
| `Ctrl+Shift+Space` | Password manager quick access |
| `Mod+LMB` | Move window |
| `Mod+RMB`, `Mod+Alt+LMB` | Resize window |

**`config/plugins/hyprsplit.nix`** (when `hyprsplit.enable`)

| Keys | Action |
|------|--------|
| `Mod+1…0`, `Mod+Shift+1…0` | This monitor's workspace 1–10, move window there silently |
| `Mod+G` | Grab windows stranded on invalid workspaces |

**`config/binds/screenshots.nix`, `config/binds/screenrecording.nix`**

| Keys | Action |
|------|--------|
| `Mod+Shift+S` | Screenshot menu |
| `Mod+Ctrl+S` | Save and copy the active window |
| `Mod+Ctrl+Shift+S` | Save and copy the focused monitor |
| `Mod+Shift+R` | Recording menu |

**`components/session/pyprland.nix`**

| Keys | Action |
|------|--------|
| `Mod+M` | Minimize to / restore from the `minimized` special workspace |
| `Mod+Ctrl+M` | Show the `minimized` special workspace |
| `Mod+Ctrl+T` | Terminal scratchpad |
| `Mod+Ctrl+V` | Volume scratchpad |
| `Mod+S` | Scratchpad menu: `b` Bluetooth, `s` Ferdium, `n` Obsidian, `m` Messages, `w` WhatsApp, `g` Gemini |

**`components/ui/workspaces/default.nix`**

| Keys | Action |
|------|--------|
| `Mod+D` | `hyprflows` submap: `1` opens the work layout, any other key leaves |

**`components/ui/dms/default.nix`** (DMS only)

| Keys | Action |
|------|--------|
| `Mod+Space` | Launcher |
| `Mod+V` | Clipboard history |
| `Mod+Comma` | DMS settings |
| `Mod+N` / `Mod+Shift+N` | Notifications / notepad |
| `Mod+Y` | Wallpaper dash |
| `Mod+Ctrl+Tab` | Overview |
| `Mod+Ctrl+Shift+L` | Lock |
| `Mod+Ctrl+Shift+R` | Restart `dms.service` |
| `Ctrl+Alt+Delete` | Process list |
| Play, Prev, Next, Mute, MicMute | Media and mute (also while locked) |
| Volume and brightness keys | ±3% volume, ±5% brightness (repeat, also while locked) |

### Screenshot menu (`Mod+Shift+S`)

- `s` save to `~/Pictures/Screenshots/screenshot-<date>-<time>.png` and copy,
  then pick a scope
- `c` copy only, then pick a scope
- `f` Flameshot GUI
- `e` capture the focused monitor and crop it in Satty

Scopes: `a` all monitors, `m` focused monitor, `w` active window, `r` region
(slurp). The first three wait 0.8s for the menu to close.

### Recording menu (`Mod+Shift+R`)

`a` focused monitor, `m` pick a monitor (wofi), `w` active window, `r` region
(slurp), `q` stop. wl-screenrec writes
`~/Videos/Recordings/recording-<date>-<time>.mp4` and notifies on start and
save.

### Unified keymap

The binds mirror `flakes/niri`: the same HJKL layers (Mod focus, +Shift monitor,
+Ctrl workspace, +Shift+Alt workspace to monitor), the same `W`/`Shift+W`/`Z`/`A`
menus, and the same screenshot and recording binds. Differences:

- No column widths in the `Mod+W` menu, no dynamic cast
  (`Mod+Insert`/`Mod+Shift+Insert`/`Mod+Delete`), no hotkey overlay (`Mod+O`)
  and no windowed fullscreen (`Mod+Ctrl+F`). niri's `Mod+Alt+F` (maximize to
  edges) is what `Mod+F` already does here.
- `Mod+Ctrl+H/L` go to the previous/next workspace; niri's go next/previous.
- Recording has no all-monitors scope: wl-screenrec captures one output.
- DMS binds are declared here. niri gets them from DMS's niri home-manager
  module, but DMS's Hyprland includes are Lua-only.
- Hyprland-only: `Mod+P` pin, `Mod+R` split, `Mod+G` hyprsplit, the pyprland
  scratchpads and `Mod+M` minimize, and `Mod+D` hyprflows.

## Plugins

Only hyprsplit, from `pkgs.hyprlandPlugins`. A plugin has to be built against
the running Hyprland, so plugins come from the same nixpkgs as the compositor.

## Check

`just check` runs `nix flake check`. The check evaluates a minimal NixOS system
(home-manager release-26.05, one user, `hyprsplit.enable = false`, `pkgs.hello`
for every app) and writes out only the toplevel `.drv` path, so nothing in the
system gets built.
