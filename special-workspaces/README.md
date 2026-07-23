# Special Workspaces

A [Noctalia v5](https://docs.noctalia.dev/v5/plugins/) bar widget for Hyprland special workspaces.

It shows one chip for every populated or currently active special workspace,
ordered by name. A filled primary chip is visible on at least one monitor; it
remains shown with zero windows while active. A muted ghost chip is populated
but hidden. Inactive empty special workspaces are not shown. Clicking a chip
toggles that special workspace through Hyprland's dispatcher.

The chips use the same compact active-pill and inactive-label treatment as
Noctalia's regular workspace widget.

## Requirements

- Noctalia v5 with plugin API 3 or newer
- Hyprland
- `hyprctl`
- `socat` (for immediate event-driven updates)

## Local development

Place or clone this checkout in a source directory as `special-workspaces/`, then
add its parent as the path source and enable the plugin:

```sh
noctalia msg plugins source add special-workspaces-dev path /absolute/path/to/source-directory
noctalia msg plugins enable jamesfeeder/special-workspaces
```

Noctalia path sources discover plugins as child directories whose name matches
the plugin id suffix. The resulting layout must be
`/absolute/path/to/source-directory/special-workspaces/plugin.toml`; directory
symlinks are not supported by the loader. In Noctalia, open **Settings →
Plugins**, enable **Special Workspaces**, then use the bar’s **Add widget**
picker to add `jamesfeeder/special-workspaces:special-workspaces`.

For a manual configuration, create a widget entry such as:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
```

Names are shown in full by default. Set `max_label_chars` to a positive value
to truncate them:

```toml
[widget.special-workspaces]
type = "jamesfeeder/special-workspaces:special-workspaces"
max_label_chars = 8
```

After editing this checkout, reload or disable/enable the plugin from Settings to load the new scripts.

## Updates and fallback

The service takes its initial snapshot from `hyprctl -j clients` and `hyprctl -j monitors`, then listens to Hyprland’s `.socket2.sock` through `socat`. Workspace, window, and monitor events refresh the chips immediately.

If `socat`, the socket, or the Hyprland environment is unavailable, it keeps the last valid result and polls every five seconds until events are available again. Workspace names are shell-quoted before dispatch, including names containing spaces or single quotes.

## Screenshots

_Screenshot placeholder: populated visible and hidden special-workspace chips on a Noctalia bar._
