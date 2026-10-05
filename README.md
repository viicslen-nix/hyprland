<div align="center">

# Hyprland

**A Lua-configured Hyprland session for NixOS, started by UWSM, shelled by DankMaterialShell.**

[![Hyprland main](https://img.shields.io/badge/Hyprland-main_@_7ebf13a-58E1FF?style=flat-square)](https://github.com/hyprwm/Hyprland/commit/7ebf13abb3c391604c60c9f627c7a403bcec8d17)
[![Config](https://img.shields.io/badge/config-Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)](https://wiki.hypr.land)
[![Cachix](https://img.shields.io/badge/cache-hyprland.cachix.org-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://hyprland.cachix.org)

</div>

A NixOS module that enables `programs.hyprland` (UWSM, XWayland) from
Hyprland's own flake and writes the whole user config through home-manager in
Lua (`configType = "lua"`): settings, binds, rules, scratchpads, per-monitor
workspaces and the DMS integration.

> [!NOTE]
> Part of [viicslen-nix/nixos](https://github.com/viicslen-nix/nixos), where it
> lives as the `flakes/hyprland` submodule. Why it is built this way — the
> Hyprland pin, `uwsm finalize`, hyprsplit as Lua, the end of pyprland — is in
> [CONTEXT.md](./CONTEXT.md). Read it before changing anything.

## Outputs

| Output | Description |
| --- | --- |
| `nixosModules.default` | The module; options under `modules.desktop.hyprland` |
| `nixosModules.hyprland` | Alias of `default` |
| `checks.x86_64-linux.default` | Evaluates a minimal NixOS system with the module and writes out its toplevel `.drv` path |
| `checks.<system>.treefmt` | treefmt (deadnix, statix, alejandra) reports no changes |
| `checks.<system>.statix` | `statix check` passes, including lints `statix fix` cannot fix |
| `formatter.<system>` | treefmt wrapper behind `nix fmt` |

Systems: `x86_64-linux`, `aarch64-linux`.

## Inputs

| Input | Role |
| --- | --- |
| `hyprland-git` | Hyprland and xdg-desktop-portal-hyprland, pinned to `7ebf13a` on main. Does **not** follow nixpkgs, so builds come from hyprland.cachix.org. Held until Quickshell and DMS cope with hyprctl dropping workspace ids |
| `hyprsplit` | Upstream's Lua library (`flake = false`) |
| `nixpkgs` | Everything else |
| `viicslen-lib` | The `wayland` helpers (`mkMenu`, `mkRecordCmd`) exposed to modules as `wlLib` |
| `treefmt-nix` | `nix fmt` and the formatting check |

> [!IMPORTANT]
> The cache is declared in the root repo's `caches.nix`. A machine that has not
> been rebuilt with it yet must pass it on the first rebuild, or Hyprland
> builds from source:
>
> ```text
> --option extra-substituters https://hyprland.cachix.org
> --option extra-trusted-public-keys hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=
> ```

## Usage

```nix
# flake.nix
inputs.hyprland = {
  url = "github:viicslen-nix/hyprland";
  inputs.nixpkgs.follows = "nixpkgs";
  # Never make hyprland-git follow nixpkgs: it voids the binary cache.
};
```

```nix
# a NixOS module
imports = [inputs.hyprland.nixosModules.default];
modules.desktop.hyprland.enable = true;
```

The root repo takes it as `path:./flakes/hyprland` and imports it in the
`desktop` preset. All user config goes through `home-manager.sharedModules`, so
home-manager must be loaded; without it only the NixOS side is applied.

## Options

All under `modules.desktop.hyprland`:

| Option | Default | Description |
| --- | --- | --- |
| `enable` | `false` | `programs.hyprland` (UWSM, XWayland), gnome-keyring, Adwaita icon/font/Qt themes |
| `terminal`, `browser`, `editor`, `fileManager`, `passwordManager` | `null` | Packages the binds launch. `null` falls back to home-manager's `modules.functionality.defaults.<name>`; with neither, the bind and its `Mod+A` entry are left out. The password manager runs with `--quick-access` |
| `portals.enable` | `true` | Configure `xdg.portal` |
| `portals.backend` | `"gtk"` | `"gtk"` \| `"gnome"` \| `"qt"`, paired with the hyprland portal. `"gnome"` also enables seahorse, gnome-settings-daemon, gnome-remote-desktop and a Settings launcher |
| `portals.extraBackends` | `[]` | Further backends to install |
| `portals.xdgOpenUsePortal` | `true` | Route `xdg-open` through the portal |
| `hyprVariables` | see below | Hyprland-only environment |
| `globalVariables` | see below | Wayland environment for every session |
| `layout` | `"dwindle"` | `"dwindle"` \| `"master"` \| `"scrolling"` |
| `hyprsplit.enable` | `true` | Per-monitor workspaces through the hyprsplit Lua library |

<details>
<summary><b>Environment variables</b></summary>

Defaults:

- `hyprVariables`: `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, and
  `XCURSOR_SIZE` when Stylix sets a cursor size.
- `globalVariables`: `XDG_SESSION_TYPE`, `CLUTTER_BACKEND`, `SDL_VIDEODRIVER`,
  `QT_QPA_PLATFORM`, `QT_WAYLAND_DISABLE_WINDOWDECORATION`,
  `MOZ_ENABLE_WAYLAND`, `NIXOS_OZONE_WL`, `ELECTRON_OZONE_PLATFORM_HINT`.

Both sets become `hl.env` calls and are written to UWSM's env files, which
UWSM sources before the compositor starts: `~/.config/uwsm/env`
(`globalVariables`) and `~/.config/uwsm/env-hyprland` (`hyprVariables`).
`globalVariables` also lands in `home.sessionVariables`, so it reaches **every**
session, niri included — anything Hyprland-only belongs in `hyprVariables`.
Null values are skipped, so `lib.mkForce null` drops a default.

</details>

<details>
<summary><b>Scrolling layout</b></summary>

`layout = "scrolling"` uses Hyprland's built-in scrolling layout tuned like
niri: new columns at 95%, width presets 30/48/65/95%, and a 3-finger gesture
that scrolls columns horizontally and changes workspace vertically (with a
vertical slide). The column settings apply whatever the layout, so a single
workspace can scroll with:

```nix
wayland.windowManager.hyprland.settings.workspace_rule = [
  { workspace = "2"; layout = "scrolling"; }
];
```

</details>

<details>
<summary><b>Monitors</b></summary>

Hosts add outputs to `wayland.windowManager.hyprland.settings.monitor` as
tables (`output`, `mode`, `position`, `scale`, `transform`, `vrr`). The flake
adds a catch-all
`{ output = ""; mode = "preferred"; position = "auto"; scale = 1; }`.

</details>

## Session

| Piece | Where it comes from |
| --- | --- |
| Startup | A `hyprland.start` hook runs `uwsm finalize`, `gnome-keyring-daemon` (secrets) and `systemctl --user start desktop-shell.target` |
| Shell | Whatever binds itself to `desktop-shell.target`, declared by the root repo's desktop shell module |
| Polkit, idle/lock, wallpaper, clipboard, OSD, notifications | DMS — this flake runs none of its own, and forces `services.hyprpaper` off |
| DMS integration | Binds, a window rule, layer rules, and guarded `require`s of the Lua files DMS writes at runtime (`dms/colors`, `outputs`, `layout`, `cursor`, `windowrules`; never `dms/binds`). Only while `modules.desktop.shell` is `"dms"` or unset |

home-manager writes these to `~/.config/hypr/`:

- `hyprland.lua` — settings, binds, rules, the `hyprflows` submap and the DMS
  includes
- `scratchpads.lua` — the `scratchpad()` and `minimize()` functions
- `hyprsplit/init.lua`, `hyprsplit-binds.lua` — when `hyprsplit.enable`

## Layout

```text
.
├── flake.nix               # inputs, nixosModules, checks, formatter
├── treefmt.nix             # deadnix, statix, alejandra
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

Binds are written as `hlLib.bind "SUPER + Q" "<Lua dispatcher>" {}`; the last
argument takes `mouse`, `locked` and `repeating`. `hlLib.exec cmd` builds an
`hl.dsp.exec_cmd` dispatcher. Menus use `wlLib.mkMenu` (wlr-which-key).

## Keybinds

`Mod` is Super. Hyprland fires **every** bind on a matching combo, so each
combo must exist in exactly one of the files below.

<details>
<summary><b>Core</b> — <code>config/binds/default.nix</code></summary>

| Keys | Action |
| --- | --- |
| `Mod+Q` | Close window |
| `Mod+F` | Maximize |
| `Mod+Shift+F` | Fullscreen |
| `Mod+T` | Toggle floating |
| `Mod+P` | Pin |
| `Mod+R` | dwindle: toggle split; scrolling: cycle column width presets; master: unbound |
| `Mod+Ctrl+Space` | Toggle group |
| `Mod+H/J/K/L`, `Mod+Left/Right` | Focus left/down/up/right |
| `Mod+Tab`, `Mod+Shift+Tab` | Cycle to next/previous window |
| `Mod+Up/Down`, `Mod+Ctrl+H/L` | Previous/next workspace on this monitor |
| `Mod+1…0`, `Mod+Shift+1…0` | Workspace 1–10, move window there silently (without hyprsplit) |
| `Mod+Shift+H/L`, `Mod+Shift+Left/Right` | Focus monitor left/right |
| `Mod+Shift+Alt+H/J/K/L`, `Mod+Shift+Alt+Left/Right` | Move workspace to monitor |
| `Mod+W` | Menu: focus `h/j/k/l`; scrolling adds column width `1–4` and `c` center column |
| `Mod+Shift+W` | Menu: move window `h/j/k/l`; scrolling moves the column with `h/l` and adds `[`/`]` consume or expel |
| `Mod+Z` | Menu: resize by 40px `h/j/k/l` |
| `Mod+A` | Menu: `s` Ferdium, `l` Discord, `e` file manager, `t` terminal, `b` browser, `p` password manager, `n` editor |
| `Mod+Return` / `Mod+B` / `Mod+E` | Terminal / browser / file manager |
| `Ctrl+Shift+Space` | Password manager quick access |
| `Mod+LMB` | Move window |
| `Mod+RMB`, `Mod+Alt+LMB` | Resize window |

</details>

<details>
<summary><b>hyprsplit</b> — <code>config/plugins/hyprsplit.nix</code> (when <code>hyprsplit.enable</code>)</summary>

| Keys | Action |
| --- | --- |
| `Mod+1…0`, `Mod+Shift+1…0` | This monitor's workspace 1–10, move window there silently |
| `Mod+G` | Grab windows stranded on invalid workspaces |

</details>

<details>
<summary><b>Screenshots and recording</b> — <code>config/binds/screenshots.nix</code>, <code>screenrecording.nix</code></summary>

| Keys | Action |
| --- | --- |
| `Mod+Shift+S` | Screenshot menu |
| `Mod+Ctrl+S` | Save and copy the active window |
| `Mod+Ctrl+Shift+S` | Save and copy the focused monitor |
| `Mod+Shift+R` | Recording menu |

Screenshot menu:

- `s` save to `~/Pictures/Screenshots/screenshot-<date>-<time>.png` and copy,
  then pick a scope
- `c` copy only, then pick a scope
- `f` Flameshot GUI
- `e` capture the focused monitor and crop it in Satty

Scopes: `a` all monitors, `m` focused monitor, `w` active window, `r` region
(slurp). The first three wait 0.8s for the menu to close.

Recording menu: `a` focused monitor, `m` pick a monitor (wofi), `w` active
window, `r` region (slurp), `q` stop. wl-screenrec writes
`~/Videos/Recordings/recording-<date>-<time>.mp4` and notifies on start, and on
save or failure.

</details>

<details>
<summary><b>Scratchpads and minimize</b> — <code>components/session/scratchpads.nix</code></summary>

| Keys | Action |
| --- | --- |
| `Mod+X` | Minimize the active window to `special:minimized`; on a special workspace, bring it back to the current one |
| `Mod+Shift+X` | Same, floating the window before minimizing it |
| `Mod+Ctrl+X` | Show/hide `special:minimized` |
| `Mod+Ctrl+T` | Terminal scratchpad (kitty) |
| `Mod+Ctrl+V` | Volume scratchpad (pwvucontrol) |
| `Mod+S` | Scratchpad menu: `b` Bluetooth, `s` Ferdium, `n` Obsidian, `m` Messages, `w` WhatsApp, `g` Gemini |

A scratchpad starts its app if no window of its class is open, and otherwise
toggles `special:<name>`. Every window of that class opens there — floating,
centred and focused — however it was launched.

</details>

<details>
<summary><b>Workflows</b> — <code>components/ui/workspaces/default.nix</code></summary>

| Keys | Action |
| --- | --- |
| `Mod+D` | `hyprflows` submap: `1` opens zen-beta on workspace 1, legcord and kitty on 11, code and kitty on 12; any other key leaves |

</details>

<details>
<summary><b>DMS</b> — <code>components/ui/dms/default.nix</code> (DMS only)</summary>

| Keys | Action |
| --- | --- |
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

</details>

<details>
<summary><b>Differences from the niri keymap</b></summary>

The binds mirror `flakes/niri`: the same HJKL layers (Mod focus, +Shift
monitor, +Ctrl workspace, +Shift+Alt workspace to monitor), the same
`W`/`Shift+W`/`Z`/`A` menus, the same `X`/`Shift+X`/`Ctrl+X` keys and the same
screenshot and recording binds. Differences:

- Column widths, column moves and the swipe gestures match niri only with
  `layout = "scrolling"`. No dynamic cast
  (`Mod+Insert`/`Mod+Shift+Insert`/`Mod+Delete`), no hotkey overlay (`Mod+O`)
  and no windowed fullscreen (`Mod+Ctrl+F`). niri's `Mod+Alt+F` (maximize to
  edges) is what `Mod+F` already does here.
- `Mod+Ctrl+H/L` go to the previous/next workspace; niri's go next/previous.
- `Mod+X` minimizes to one special workspace here; on niri it assigns the
  window to a niri-scratchpad register.
- Recording keeps the `w` active-window scope, which niri cannot offer.
- DMS binds are declared here. niri includes DMS's `dms/binds.kdl`; Hyprland
  would fire both copies of every duplicate, so `dms/binds.lua` is left out.
- Hyprland-only: `Mod+P` pin, `Mod+R` split or width presets, `Mod+G`
  hyprsplit, the app scratchpads (`Mod+S`, `Mod+Ctrl+T`, `Mod+Ctrl+V`) and
  `Mod+D` hyprflows.

</details>

## Development

| Command | What it does |
| --- | --- |
| `nix fmt` | deadnix, statix, then alejandra via treefmt |
| `just check` | `nix flake check --print-build-logs` |

`checks.x86_64-linux.default` evaluates a minimal NixOS system (home-manager
`2c0350c`, the rev hosts use; one user; `hyprsplit.enable = true`; `pkgs.hello`
for every app) and writes out only the toplevel `.drv` path, so nothing in the
system gets built. It does not validate the Lua.

To validate the rendered Lua against the compositor that will run it, copy the
config into a real directory first. `-c` resolves symlinks, and the
home-manager files point into `/nix/store`, where `require()` would not find
the other files:

```sh
d=$(mktemp -d)
cp -rL ~/.config/hypr "$d/"
XDG_CONFIG_HOME="$d" Hyprland --verify-config -c "$d/hypr/hyprland.lua"
```

It prints `config ok`. Outside a session, also set
`XDG_RUNTIME_DIR=$(mktemp -d)`; Hyprland exits without one. The check catches
unknown keys, fields and dispatcher arguments, not runtime behaviour.

After a change to this subflake's files, commit here; after a change to its
inputs, also run `nix flake update hyprland` in the root repo, since hosts
build the root lock's pins.
