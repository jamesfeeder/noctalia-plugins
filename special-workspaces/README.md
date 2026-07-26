# Special Workspaces

A [Noctalia v5](https://docs.noctalia.dev/v5/plugins/) bar widget for Hyprland special workspaces.

It shows one chip for every populated or currently active special workspace,
ordered by name. A filled primary chip is visible on at least one monitor; it
remains shown with zero windows while active. A secondary chip is populated but
hidden. Inactive empty special workspaces are not shown.

The chips use the same compact active-pill and inactive-label treatment as
Noctalia's regular workspace widget.

## Plugin

| Field | Value |
| --- | --- |
| id | `jamesfeeder/special-workspaces` |
| version | `1.1.3` |
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
to truncate them. Hidden workspace chips use the secondary palette color by
default; set `secondary_inactive` to `false` to make them transparent:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
max_label_chars = 8
secondary_inactive = false
```

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
