# Hyprland

NixOS module for a Hyprland session started through UWSM, with
DankMaterialShell (DMS) as the shell. The config is written in Lua
(home-manager `configType = "lua"`) for Hyprland's main branch. Why it is built
this way is in [CONTEXT.md](./CONTEXT.md).

```nix
imports = [inputs.hyprland.nixosModules.default];
modules.desktop.hyprland.enable = true;
```

Settings, binds and rules are applied through `home-manager.sharedModules`, so
they need home-manager loaded.

## Inputs and binary cache

- `hyprland-git`: Hyprland and xdg-desktop-portal-hyprland, pinned to commit
  `7ebf13a` on main. It does not follow nixpkgs, so its builds come from
  hyprland.cachix.org. The pin stays until Quickshell and DMS handle the
  removal of workspace ids from hyprctl (see CONTEXT.md).
- `hyprsplit`: upstream's Lua library (`flake = false`).
- `nixpkgs`, `viicslen-lib`: everything else.

The cache is declared in the root `caches.nix`. A machine that has not been
rebuilt with it yet needs it passed on the first rebuild:

```text
--option extra-substituters https://hyprland.cachix.org
--option extra-trusted-public-keys hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=
```

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

  hyprsplit.enable = true;  # per-monitor workspaces (hyprsplit Lua library)
}
```

`portals.backend = "gnome"` also enables seahorse, gnome-settings-daemon,
gnome-remote-desktop and a Settings launcher.

Both variable sets become `hl.env` calls and are written to UWSM's env files,
which UWSM sources before the compositor starts: `~/.config/uwsm/env`
(`globalVariables`) and `~/.config/uwsm/env-hyprland` (`hyprVariables`).
`globalVariables` also lands in `home.sessionVariables`. Null values are
skipped, so `lib.mkForce null` drops a default.

Hosts add outputs to `wayland.windowManager.hyprland.settings.monitor` as
tables (`output`, `mode`, `position`, `scale`, `transform`, `vrr`). The flake
adds a catch-all
`{ output = ""; mode = "preferred"; position = "auto"; scale = 1; }`.

## Session

A `hyprland.start` hook runs `uwsm finalize`, `gnome-keyring-daemon` (secrets)
and `desktop-shell.target`. The target is declared by the root repo's desktop
shell module; the selected shell binds itself to it.

DMS supplies the polkit agent, idle and lock, wallpaper, clipboard history, OSD
and notifications. This flake adds its binds, window rule and layer rules, and
loads the Lua files DMS writes at runtime (`dms/colors`, `outputs`, `layout`,
`cursor`, `windowrules`, never `dms/binds`). All of that only while
`modules.desktop.shell` is `"dms"` (or unset).

## Files

home-manager writes these to `~/.config/hypr/`:

- `hyprland.lua`: settings, binds, rules, the `hyprflows` submap and the DMS
  includes
- `scratchpads.lua`: the `scratchpad()` and `minimize()` functions
- `hyprsplit/init.lua`, `hyprsplit-binds.lua`: when `hyprsplit.enable`

```text
.
├── flake.nix               # inputs, nixosModules.default, eval-only check
├── Justfile                # just check
├── default.nix             # options, programs.hyprland, portals, home-manager wiring, hlLib
├── config/
│   ├── settings.nix        # settings.config tree, animations, gesture, hyprland.start hook
│   ├── environment.nix     # hyprVariables/globalVariables -> hl.env, UWSM env files
│   ├── rules.nix           # workspace and window rules
│   ├── rules/              # system, jetbrains, one-password
│   ├── binds/
│   │   ├── default.nix     # core binds, Mod+W/Shift+W/Z/A menus, digits without hyprsplit
│   │   ├── screenshots.nix
│   │   └── screenrecording.nix
│   └── plugins/
│       ├── default.nix     # imports hyprsplit.nix when hyprsplit.enable
│       └── hyprsplit.nix   # hyprsplit-binds.lua
└── components/
    ├── session/scratchpads.nix   # scratchpads, minimize
    ├── tools/flameshot.nix       # flameshot.ini, Stylix colours
    └── ui/
        ├── dms/default.nix       # DMS binds, rules, runtime Lua includes
        └── workspaces/default.nix  # hyprflows submap
```

Binds are written with `hlLib.bind "SUPER + Q" "<Lua dispatcher>" {}`. The last
argument takes `mouse`, `locked` and `repeating`. `hlLib.exec cmd` builds an
`hl.dsp.exec_cmd` dispatcher.

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

**`components/session/scratchpads.nix`**

| Keys | Action |
|------|--------|
| `Mod+X` | Minimize the active window to `special:minimized`; on a special workspace, bring it back to the current one |
| `Mod+Shift+X` | Same, floating the window before minimizing it |
| `Mod+Ctrl+X` | Show/hide `special:minimized` |
| `Mod+Ctrl+T` | Terminal scratchpad (kitty) |
| `Mod+Ctrl+V` | Volume scratchpad (pwvucontrol) |
| `Mod+S` | Scratchpad menu: `b` Bluetooth, `s` Ferdium, `n` Obsidian, `m` Messages, `w` WhatsApp, `g` Gemini |

Scratchpads and minimize are plain Lua; pyprland is no longer used. A
scratchpad starts its app if no window of its class is open, and otherwise
toggles `special:<name>`. Every window of that class opens there, floating,
centred and focused, with `special:<name>` shown, however it was launched.

**`components/ui/workspaces/default.nix`**

| Keys | Action |
|------|--------|
| `Mod+D` | `hyprflows` submap: `1` opens zen-beta on workspace 1, legcord and kitty on 11, code and kitty on 12; any other key leaves |

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
| `Mod+M` | Process list (focus or toggle) |
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
`~/Videos/Recordings/recording-<date>-<time>.mp4` and notifies on start, and on
save or failure.

### Unified keymap

The binds mirror `flakes/niri`: the same HJKL layers (Mod focus, +Shift monitor,
+Ctrl workspace, +Shift+Alt workspace to monitor), the same `W`/`Shift+W`/`Z`/`A`
menus, the same `X`/`Shift+X`/`Ctrl+X` keys and the same screenshot and
recording binds. Differences:

- No column widths in the `Mod+W` menu, no dynamic cast
  (`Mod+Insert`/`Mod+Shift+Insert`/`Mod+Delete`), no hotkey overlay (`Mod+O`)
  and no windowed fullscreen (`Mod+Ctrl+F`). niri's `Mod+Alt+F` (maximize to
  edges) is what `Mod+F` already does here.
- `Mod+Ctrl+H/L` go to the previous/next workspace; niri's go next/previous.
- `Mod+X` minimizes to one special workspace here; on niri it assigns the
  window to a niri-scratchpad register.
- Recording keeps the `w` active-window scope, which niri cannot offer.
- DMS binds are declared here. niri includes DMS's `dms/binds.kdl`; Hyprland
  would fire both copies of every duplicate, so `dms/binds.lua` is left out.
- Hyprland-only: `Mod+P` pin, `Mod+R` split, `Mod+G` hyprsplit, the app
  scratchpads (`Mod+S`, `Mod+Ctrl+T`, `Mod+Ctrl+V`) and `Mod+D` hyprflows.

## Checking changes

`just check` runs `nix flake check`. The check evaluates a minimal NixOS system
(home-manager `2c0350c`, the rev hosts use; one user; `hyprsplit.enable = true`;
`pkgs.hello` for every app) and writes out only the toplevel `.drv` path, so
nothing in the system gets built. It does not validate the Lua.

To validate the rendered Lua against the compositor that will run it, copy the
config into a real directory first. `-c` resolves symlinks, and the
home-manager files point into `/nix/store`, where `require()` would not find
the other files.

```sh
d=$(mktemp -d)
cp -rL ~/.config/hypr "$d/"
XDG_CONFIG_HOME="$d" Hyprland --verify-config -c "$d/hypr/hyprland.lua"
```

It prints `config ok`. Outside a session, also set
`XDG_RUNTIME_DIR=$(mktemp -d)`; Hyprland exits without one. The check catches
unknown keys, fields and dispatcher arguments, not runtime behaviour.
