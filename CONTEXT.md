# CONTEXT

Why this flake looks the way it does. Options and binds are documented in
[README.md](./README.md).

## `configType` is pinned to hyprlang

home-manager defaults `wayland.windowManager.hyprland.configType` to Lua from
`home.stateVersion` 26.05. Every setting here is written for hyprlang (bind
strings, `$mod`, `windowrule` lists), and rendered as Lua it is an invalid
config. That is why `default.nix` sets `configType = "hyprlang"` explicitly.

This only holds for now. Hyprland's main branch reads Lua only, so this config
needs a Lua port before nixpkgs moves past the 0.56 series.

Don't run `dms setup` for Hyprland. DMS's Hyprland integration is Lua, and when
a `hyprland.lua` exists DMS moves a stray `hyprland.conf` aside, and that
`hyprland.conf` is the file home-manager writes from this flake.

## Everything comes from nixpkgs, not the Hyprland flake

This flake used to take Hyprland, its plugins, pyprland, hypridle, hyprpaper and
noctalia as flake inputs. That caused three problems:

- Hyprland only loads a plugin built against the running compositor's API hash.
  hyprsplit from its flake input was built against a different Hyprland commit
  and refused to load. The workspace digit binds dispatch `split:*`, so they
  stopped working too. `pkgs.hyprlandPlugins.hyprsplit` is built against
  `pkgs.hyprland`.
- The root repo forces these inputs to follow its nixpkgs, so their outputs
  never matched what hyprland.cachix.org holds, and Hyprland built from source.
- The upstream NixOS and home-manager modules only set `mkDefault` packages,
  and those were overridden anyway.

Dropping the inputs removed about 60 nodes from the root lock.

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

That is why the keyring, the shell target and pyprland start from Hyprland's
`exec-once` rather than from systemd units.

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
built at eval time, so grepping the bind strings misses them: the menus, and the
`Mod+1…0` loops, which appear in both `binds/default.nix` and
`plugins/hyprsplit.nix`, gated on opposite values of `hyprsplit.enable`.
