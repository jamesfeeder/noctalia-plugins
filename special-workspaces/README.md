# Special Workspaces

A [Noctalia v5](https://docs.noctalia.dev/v5/plugins/) bar widget for Hyprland special workspaces.

It shows one chip for every populated or currently active special workspace,
ordered by name. A filled primary chip is visible on at least one monitor; it
remains shown with zero windows while active. A secondary chip is populated but
hidden. Inactive empty special workspaces are not shown, and populated inactive
workspaces can optionally be hidden too.

The chips use compact borderless fills with a configurable corner radius.

## Plugin

| Field | Value |
| --- | --- |
| id | `jamesfeeder/special-workspaces` |
| version | `1.2.0` |
| plugin API | `3` |
| widget | `jamesfeeder/special-workspaces:special-workspaces` |

## Requirements

- Noctalia v5 with plugin API 3 or newer.
- Hyprland.
- `hyprctl`.
- `socat` for immediate event-driven updates.

## Usage

Enable the plugin:

```sh
noctalia msg plugins enable jamesfeeder/special-workspaces
```

In Noctalia, open **Settings → Plugins**, enable **Special Workspaces**, then
use the bar's **Add widget** picker to add
`jamesfeeder/special-workspaces:special-workspaces`.

For a manual configuration, create a widget entry such as:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
```

## Settings

Names are shown in full by default. Set `max_label_chars` to a positive value
to truncate them. Active and inactive workspaces can independently use a
palette fill or a transparent ghost style:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
max_label_chars = 8
active_style = "fill"
inactive_style = "ghost"
```

Set `capsule_radius` in logical pixels. The default is `8`:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
capsule_radius = 4
```

Set content padding and minimum capsule length along the bar in logical pixels.
Defaults are `5` and `35`:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
capsule_padding = 6
capsule_min_width = 40
```

Negative radius, padding, and minimum-width values use `0`.

On vertical bars, capsule axes swap: capsules use a fixed width and grow
vertically. Workspace names are truncated first, then displayed one Unicode
character per line from top to bottom.

Set `hide_inactive` to show only currently active special workspaces. Active
workspaces remain visible even when empty:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
hide_inactive = true
```

While inactive workspaces are hidden, `inactive_style` has no runtime effect and
is omitted from the widget settings UI.

## Notes

The service takes its initial snapshot from `hyprctl -j clients` and `hyprctl -j monitors`, then listens to Hyprland’s `.socket2.sock` through `socat`. Workspace, window, and monitor events refresh the chips immediately.

If `socat`, the socket, or the Hyprland environment is unavailable, it keeps the last valid result and polls every five seconds until events are available again. Workspace names are shell-quoted before dispatch, including names containing spaces or single quotes.

## Local development

Add the repository root as a Noctalia path source:

```sh
noctalia msg plugins source add jamesfeeder-dev path /absolute/path/to/noctalia-plugins
noctalia msg plugins enable jamesfeeder/special-workspaces
```

Noctalia discovers child plugin directories matching their id suffix. Directory
symlinks are not supported. Luau edits hot-reload; after manifest changes,
reload the config or disable and re-enable the plugin.

Run repository checks from the checkout root:

```sh
./.tools/check.sh
```

## TODO

- Add an optional 960×540 `thumbnail.webp` showing visible and hidden chips.
- Add CI validation after repository-local checks stabilize.
