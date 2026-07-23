# Project Context

## Purpose

`jamesfeeder/special-workspaces` is a Noctalia v5 bar plugin for Hyprland. It gives populated special workspaces a persistent, directly clickable representation in the bar.

## Domain language

| Term | Meaning |
| --- | --- |
| Special workspace | A Hyprland workspace whose reported name has the `special:` prefix. The plugin displays the suffix. |
| Populated | Contains one or more Hyprland clients. Only populated workspaces are rendered. |
| Active | Visible on at least one monitor through `monitor.specialWorkspace`; this does not mean focused. |
| Inactive | Populated but not currently visible on any monitor. |
| Snapshot | A combined reading of `hyprctl -j clients` and `hyprctl -j monitors`. |
| Event stream | Hyprland `.socket2.sock`, consumed through `socat` to trigger immediate snapshot refreshes. |

## Data flow

```text
Hyprland clients + monitors ──► service snapshot ──► noctalia.state
Hyprland socket events ───────► refresh snapshot ──► widget chips
widget chip click ────────────► hyprctl togglespecialworkspace <name>
```

The service uses five-second polling while the event stream is unavailable or reconnecting. It does not replace a previously published state following a transient command failure.

## User-visible behavior

- Chips are sorted by workspace name.
- Visible chips use the `primary` button variant.
- Hidden populated chips use the `ghost` button variant.
- Tooltips include workspace name, visibility state, and window count.
- Workspace names may contain spaces or single quotes; dispatch commands quote them safely.
- Noctalia requires statically declared UI callback globals. The widget maintains 64 callback slots and disables any overflow chip.

## Constraints

- Noctalia plugin APIs are beta and may change.
- The plugin requires `hyprctl` and `socat`.
- There is intentionally no remote publishing or community-plugin submission workflow in this repository.
