# Project Context

## Purpose

`jamesfeeder/special-workspaces` is a Noctalia v5 bar plugin for Hyprland. It gives populated and currently active special workspaces a visual representation in the bar.

## Domain language

| Term | Meaning |
| --- | --- |
| Special workspace | A Hyprland workspace whose reported name has the `special:` prefix. The plugin displays the suffix. |
| Populated | Contains one or more Hyprland clients. Populated workspaces remain rendered while inactive. |
| Active | Visible on at least one monitor through `monitor.specialWorkspace`; this does not mean focused. |
| Inactive | Populated but not currently visible on any monitor. |
| Snapshot | A combined reading of `hyprctl -j clients` and `hyprctl -j monitors`. |
| Event stream | Hyprland `.socket2.sock`, consumed through `socat` to trigger immediate snapshot refreshes. |

## Data flow

```text
Hyprland clients + monitors ──► service snapshot ──► noctalia.state
Hyprland socket events ───────► refresh snapshot ──► widget chips
```

The service uses five-second polling while the event stream is unavailable or reconnecting. It does not replace a previously published state following a transient command failure.

## User-visible behavior

- Chips are sorted by workspace name.
- Active special workspaces remain visible with a zero window count when empty.
- Inactive empty special workspaces are not rendered.
- Chips follow Noctalia's regular workspace treatment with slim 16px pills and
  fully rounded ends.
- Visible chips use a rounded `primary` container.
- Hidden populated chips use a rounded `secondary` container by default.
- Workspace labels show their full name by default and can be truncated with
  the widget's maximum-label-characters setting.

## Constraints

- Noctalia plugin APIs are beta and may change.
- The plugin requires `hyprctl` and `socat`.
- Publishing and catalog concerns belong to the repository root, not this
  plugin's runtime domain.
