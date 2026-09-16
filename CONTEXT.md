# CONTEXT

Why this flake looks the way it does. Options and binds are documented in
[README.md](./README.md).

## Hyprland comes from its own flake, without nixpkgs follows

The config is Lua, written for Hyprland main. Hyprland and
xdg-desktop-portal-hyprland come from the `hyprland-git` input; everything else
comes from nixpkgs. The NixOS module is still nixpkgs' `programs.hyprland`, and
only its `package` and `portalPackage` point at the input.

`hyprland-git` must not follow nixpkgs, here or in the root flake.
hyprland.cachix.org holds builds made against Hyprland's own nixpkgs pin.
Following ours changes every store path, the cache misses, and Hyprland builds
from source. That already happened once, when this flake took Hyprland as an
input and the root forced it onto its nixpkgs. The root `hyprland` input
follows only this flake's own `nixpkgs` and `viicslen-lib`, which leaves the
nested one alone. The cost is a second nixpkgs in the eval and in Hyprland's
closure.

The cache is a `desktop`-scope entry in the root `caches.nix`, with no
`ownNixpkgs`, because this is a real input, not an omniflake index entry. The
running daemon only learns about it on a rebuild, and the cache is new, so the
first rebuild that pulls Hyprland needs:

```text
--option extra-substituters https://hyprland.cachix.org
--option extra-trusted-public-keys hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=
```

Hosts build the root lock's copy of `hyprland-git` and its nixpkgs. A bump is
`nix flake lock` here, then `nix flake update hyprland` at the root.

## Pinned at `7ebf13a`

The next commit on main, `e9e2f64`, removes the workspace `id` from every
hyprctl JSON object. Quickshell's Hyprland IPC still parses that id
(quickshell-mirror/quickshell#1149, open), so DMS's workspace switcher and
overview break on any later commit. `7ebf13a` is already Lua-only, already
has the `MANAGERPID` change (see below), and both packages are in the cache.

Move off it only when all three hold:

1. quickshell#1149 is fixed.
2. DMS and Quickshell are bumped in the **root** `flake.lock`
   (`just update-subflake dms`). Hosts build the root's pins, not
   `flakes/dms/flake.lock`, and the root's DMS node has lagged behind the
   subflake before (`8594a41` vs `c8ec045`).
3. DMS's own QML is re-checked for `ws.id` (WorkspaceSwitcher,
   OverviewWidget). A Quickshell fix alone may not cover it.

After `e9e2f64`, `LuaWorkspace.id` is nil for special and named workspaces.
Any Lua that does arithmetic on it must guard against that; hyprsplit already
does.

## Startup lives in `hyprland.start`, with `uwsm finalize`

Since `34839b4`, Hyprland skips `systemctl --user import-environment` and the
D-Bus activation environment update when `MANAGERPID` is set, and uwsm's
systemd unit sets it. uwsm then expects the compositor to run `uwsm finalize`
itself. Without that, `graphical-session.target` is never reached, and
`desktop-shell.target` (`BindsTo`/`After` that target) never starts a shell.

`hl.exec_cmd` doesn't wait, so finalize, the keyring and the shell target all
start together. The shell still comes up after finalize because of the
target's `After=`. This has not been tested in a live session.

Everything that used to be `exec-once` belongs in the hook. `hyprctl reload`
re-runs all of `hyprland.lua`. It also clears `package.loaded`, so the required
files re-run too, and DMS reloads after every file it writes. A top-level
`hl.exec_cmd` starts another copy on each reload, and it also crashes
`Hyprland --verify-config` (exit 139). `hyprland.start` fires only once.

## hyprsplit is a Lua library, not a plugin

On main the compiled plugin API can no longer add dispatchers:
`addDispatcherV2` returns false. That makes the C++ hyprsplit, and its
`split:*` binds, dead. A compiled plugin would also have to match the running
compositor's API hash, which nixpkgs' `hyprlandPlugins` do not. Upstream ships
`init.lua` instead, taken from the `hyprsplit` input (`flake = false`).

- **`xdg.configFile`, not `extraLuaFiles`.** home-manager `2c0350c` checks
  whether content is a path with `lib.isStorePath`, which is false for a file
  *inside* a store path (`/nix/store/…-source/init.lua`). The path string is
  then written as the file's text, and `require("hyprsplit")` fails. HM
  `f4cfe696`, one commit later, fixes it; once hosts are past it,
  `extraLuaFiles` would work. The flake check pins HM `2c0350c` because the
  Lua renderer differs between commits.
- **The binds live in their own required file** (`hyprsplit-binds.lua`).
  Hyprland's `require` records an error from a required file and carries on,
  so a broken library loses only these binds. Calling `hs` from
  `settings.bind` would abort the rest of `hyprland.lua`.
- **No `plugin.hyprsplit.*` settings.** Nothing registers those keys, so
  `hl.config` reports `unknown config key` on every load. The library's
  defaults (10 workspaces, not persistent) match what the plugin was set to.

## pyprland is gone

`pypr toggle_special` reads the active window's `workspace.id`, which main
drops right after the pin. The rest of pyprland talks to an IPC that main is
actively changing. `components/session/scratchpads.nix` replaces it with
`scratchpads.lua` plus one window rule per pad.

- `scratchpad` and `minimize` must stay global functions. The `Mod+S` menu runs
  `hyprctl eval 'scratchpad("notes")'`, which executes in the config's Lua
  state, and a `local function` would be unreachable from there.
- `minimize` restores with a normal move, without `follow = false`. That move
  closes the special workspace and focuses the window. A silent move would leave
  the special workspace open over it.
- The pad rule is not `silent`. A window mapped `silent` never takes focus, and
  toggling a still-empty special workspace focuses nothing, so a freshly started
  pad showed up with the keyboard still on the window underneath. A non-silent
  map opens `special:<name>` and focuses the window itself, so `scratchpad`
  starts the app *or* toggles, never both.

What pyprland did that this does not:

- `unfocus = "hide"`: pads no longer hide when they lose focus.
- The `fromTop`/`fromRight` slide animations.
- Starting the non-lazy pads (term, services, notes, messages, whatsapp,
  gemini) at login. Every pad now starts on its first toggle.
- PID tracking. Pads are matched by class only, so every window of a pad's
  class opens that pad's special workspace, however it was launched. Ferdium
  from `Mod+A` and pwvucontrol or Overskride from the DMS control center
  included.
- The monitors plugin. Hosts placed outputs relative to named monitors
  (`topOf`/`leftOf`), which Lua `monitor` positions cannot express. Use
  explicit coordinates or DMS's `outputs.lua`.

Add a `hl.on("window.active", …)` hide or a `specialWorkspace` animation only
if these are missed.

## `Mod+X`, not `Mod+M`

Minimize moved from `Mod+M` to `Mod+X` / `Mod+Shift+X` / `Mod+Ctrl+X` to match
niri. On niri, DMS's `binds.kdl` owns `Mod+M` (process list) and overrides
ours, so the scratchpad keys moved there first. Hyprland gives `Mod+M` to the
DMS process list too, declared with the other DMS binds.

## hyprctl speaks Lua

`hyprctl dispatch <arg>` runs `return hl.dispatch(<arg>)`, so a legacy
dispatcher string like `movefocus l` is a Lua error. The `Mod+W`, `Mod+Shift+W`
and `Mod+Z` menus pass `hl.dsp.*` expressions through `escapeShellArg`.

Scripts take `hyprctl` from `osConfig.programs.hyprland.package`, the running
compositor, never from `pkgs.hyprland`. The screenshot and recording jq reads
only `.focused`, `.name`, `.at` and `.size`, which survive `e9e2f64`.

## Writing the Lua settings

- Keys that several modules set (`bind`, `window_rule`, `layer_rule`, `env`,
  `monitor`) are lists, so the modules merge. `settings.config` is the one
  attrset tree.
- Hyprland maps `-` to `_` in option names: `tap_to_click`, not
  `tap-to-click`.
- Rules carry no `name`, since Hyprland merges rules that share one. Effects
  with the same match go in one table.
- A Lua syntax error in any `mkLuaInline` rejects the whole file. Run
  `Hyprland --verify-config` (README) after touching one.

## DMS owns the session services

DMS already provides the polkit agent, idle and lock, wallpaper, clipboard
history and OSD, so this flake runs none of its own:

- Only one polkit agent can register per session. With hyprpolkitagent enabled,
  it won the race and DMS's agent failed to register.
- The hypridle and hyprpaper configs that duplicated DMS were also broken
  against current versions of those tools.
- On hosts with both niri and Hyprland, a user unit
  `WantedBy=graphical-session.target` starts under either compositor. A
  Hyprland-only service would leak into niri sessions.
- stylix's hyprland target turns on `services.hyprpaper` whenever home-manager's
  Hyprland is enabled, which put a hyprpaper unit into niri sessions on
  dostov-dev and competed with DMS's wallpaper; the module forces it off.

That is why the keyring and the shell target start from the `hyprland.start`
hook rather than from systemd units.

## DMS's runtime Lua files

DMS writes `~/.config/hypr/dms/{colors,outputs,layout,cursor,windowrules,binds}.lua`
and runs `hyprctl reload` after each write. It writes them even though
home-manager's `hyprland.lua` is read-only, because Quickshell reports
`Hyprland.usingLua` on main. `components/ui/dms` requires them from
`extraConfig`, which renders last, so values DMS sets override the same keys
from `settings.nix`.

- Each require is guarded by `package.searchpath`. A missing module re-raises
  and aborts the file, and the files don't exist until DMS first writes them.
- Each line is a literal `require("dms.<name>")`. DMS detects the include by
  matching that text, so a Lua loop over the names would hide it.
- `binds` is left out. Hyprland fires every matching bind, and `dms/binds.lua`
  binds `Mod+X`, `Mod+T` and `Mod+W`, which this flake also uses. DMS's binds
  are declared by hand instead.

Don't run `dms setup` for Hyprland: it writes its own `hyprland.lua` over the
one home-manager manages.

## `desktop-shell.target`

`settings.nix` starts `desktop-shell.target`, not DMS. The target is declared by
the root repo's desktop shell module, and the selected shell binds itself to it,
so the compositor never names a shell. Without that module the target does not
exist and no shell autostarts.

## No Screenshot portal routing

The niri flake routes `org.freedesktop.impl.portal.Screenshot` to
xdg-desktop-portal-wlr, because niri's GNOME portal path errors on multiple
outputs (niri#117). Hyprland doesn't need that: xdg-desktop-portal-hyprland
implements Screenshot itself, with grim over all outputs.

## Bind collisions

Hyprland has no shadowing: every bind whose mods and key match will fire. That
is how `Mod+Ctrl+L` once switched workspace and locked the screen at the same
time. Binds are split across the files listed in the README. Some combos are
built at eval time or in Lua, so grepping the bind strings misses them: the
menus, and the `Mod+1…0` loops. Those loops appear both as a Nix loop in
`binds/default.nix` and as a Lua loop in `hyprsplit-binds.lua`, gated on
opposite values of `hyprsplit.enable`.

## Not yet checked in a live session

`--verify-config` checks names and arguments, not behaviour. These still need
a real session:

- `uwsm finalize` reaching `graphical-session.target`, and the shell waiting
  for it.
- DMS workspace widgets at `7ebf13a`.
- hyprsplit on two or more monitors.
- `hyprctl dispatch` and `hyprctl eval` run from the wlr-which-key menus.
- A pad's first start opening `special:<pad>` with the window focused.
