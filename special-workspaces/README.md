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

Configure the widget through **Settings → Bar**, or add values to its TOML
entry:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
max_label_chars = 8
hide_inactive = false
capsule_radius = 4
capsule_padding = 6
capsule_min_width = 40
active_style = "fill"
inactive_style = "ghost"
```

| Setting | Default | Description |
| --- | ---: | --- |
| `max_label_chars` | `0` | Maximum characters shown from each workspace name. `0` shows the full name. |
| `hide_inactive` | `false` | Hide populated workspaces unless they are currently visible on a monitor. |
| `capsule_radius` | `8` | Capsule corner radius in logical pixels. |
| `capsule_padding` | `5` | Space before and after the label along the bar axis. |
| `capsule_min_width` | `35` | Minimum capsule length along the bar axis. |
| `active_style` | `"fill"` | Active capsule style: `"fill"` or `"ghost"`. |
| `inactive_style` | `"fill"` | Inactive capsule style: `"fill"` or `"ghost"`. |

### Visibility and labels

Active workspaces remain visible even when empty. Inactive workspaces appear
only while populated, unless `hide_inactive` is enabled; then only workspaces
currently visible on a monitor are shown.

Workspace names are shown in full when `max_label_chars` is `0`. Positive
values truncate each name to that many Unicode characters.

### Capsule appearance

Fill style uses the palette's `primary` colors for active workspaces and
`secondary` colors for inactive workspaces. Ghost style removes the fill;
active labels use `primary` text and inactive labels use `on_surface` text.
Active and inactive styles are independent. When `hide_inactive` is enabled,
`inactive_style` has no runtime effect and is hidden from the settings UI.

Radius, padding, and minimum length use logical pixels. Values below `0` are
treated as `0`.

### Vertical bars

On horizontal bars, capsule length is its width. On vertical bars, capsule
length is its height: capsules use a fixed width and grow vertically.
Workspace names are truncated first, then displayed one Unicode character per
line from top to bottom.

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
