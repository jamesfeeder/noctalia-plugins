# Agent Guide

## Agent skills

### Issue tracker

Issues use local Markdown under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five standard triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context project. See `docs/agents/domain.md`.

## Project

This repository is a Noctalia v5 plugin with id `jamesfeeder/special-workspaces`.
It displays populated Hyprland special workspaces as clickable bar chips.

## Files

- `plugin.toml` — plugin metadata and entry declarations.
- `service.luau` — snapshots Hyprland state, watches `.socket2.sock`, and publishes shared state.
- `widget.luau` — renders the Noctalia declarative bar widget and dispatches chip clicks.
- `README.md` — installation and behavior documentation.

## Development rules

- Keep the manifest compatible with Noctalia plugin API 3 unless a newer API capability is required.
- Keep all state exchanged between entries plain data through `noctalia.state`; entries run in isolated VMs.
- Do not render empty special workspaces.
- `active` means visible on any monitor, not focused.
- Preserve alphabetical ordering by workspace name.
- Shell-quote workspace names before including them in a `hyprctl dispatch` command.
- Keep chip callbacks as statically declared globals; Noctalia seals `_G` after script load.
- Retain the last valid state when `hyprctl` fails. Socket failures must keep the polling fallback available.
- Use `barWidget.render()` and keyed `ui.button` children for widget UI changes.

## Validation

Run the built-in offline lint after changing the manifest or scripts:

```sh
noctalia plugins lint .
```

For live checks, ensure the checkout directory is named `special-workspaces`, add its parent as a Noctalia path source, enable the plugin, then test visible, hidden, empty, moved, and quoted-name special workspaces. Noctalia does not load entry scripts through a symlinked plugin directory.
