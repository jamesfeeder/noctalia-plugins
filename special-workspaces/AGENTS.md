# Special Workspaces Agent Guide

Read root `AGENTS.md` for repository rules and this directory's `CONTEXT.md`
before changing behavior.

## Plugin

This directory is a Noctalia v5 plugin with id
`jamesfeeder/special-workspaces`.
It displays populated Hyprland special workspaces as bar chips.

## Files

- `plugin.toml` — plugin metadata and entry declarations.
- `service.luau` — snapshots Hyprland state, watches `.socket2.sock`, and publishes shared state.
- `widget.luau` — renders the Noctalia declarative bar widget.
- `README.md` — installation and behavior documentation.

## Development rules

- Keep the manifest compatible with Noctalia plugin API 3 unless a newer API capability is required.
- Keep all state exchanged between entries plain data through `noctalia.state`; entries run in isolated VMs.
- Render active special workspaces even when empty. Do not render inactive empty
  special workspaces. When `hide_inactive` is enabled, do not render any
  inactive special workspaces.
- `active` means visible on any monitor, not focused.
- Preserve alphabetical ordering by workspace name.
- Render compact chips as borderless rows. Active and inactive states each
  support independent fill and ghost styles. Control their radius with the
  `capsule_radius` widget setting, which defaults to 8px and clamps negative
  values to 0px. Control horizontal content padding with `capsule_padding`
  (default 5px) and minimum width with `capsule_min_width` (default 35px);
  both apply to active and inactive capsules and clamp negative values to 0px.
- Retain the last valid state when `hyprctl` fails. Socket failures must keep the polling fallback available.
- Use `barWidget.render()` and keyed layout children for widget UI changes.

## Validation

Run repository checks after changing the manifest, docs, translations, or
scripts:

```sh
./.tools/check.sh
```

For live checks, ensure the checkout directory is named `special-workspaces`, add its parent as a Noctalia path source, enable the plugin, then test visible, hidden, empty, moved, and quoted-name special workspaces. Noctalia does not load entry scripts through a symlinked plugin directory.
