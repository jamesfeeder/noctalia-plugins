# Noctalia Plugins

Personal, multi-plugin source for [Noctalia](https://noctalia.dev/) plugins.

## Plugins

| Plugin | Description |
| --- | --- |
| [`jamesfeeder/special-workspaces`](special-workspaces/) | Show populated Hyprland special workspaces as bar chips. |

## Add this source

Add this Git repository as a Noctalia plugin source, then enable a plugin by
its id:

```sh
noctalia msg plugins source add jamesfeeder git https://github.com/jamesfeeder/noctalia-plugins.git
noctalia msg plugins enable jamesfeeder/special-workspaces
```

For local development, add the checkout as a path source:

```sh
noctalia msg plugins source add jamesfeeder-dev path /absolute/path/to/noctalia-plugins
noctalia msg plugins enable jamesfeeder/special-workspaces
```

## Repository layout

Each plugin lives in a top-level directory matching the part of its id after
`jamesfeeder/`:

```text
my-plugin/
  plugin.toml
  README.md
  translations/en.json
  *.luau
  thumbnail.webp        # optional, 960×540
```

`catalog.toml` indexes every plugin. It is generated from manifests and
committed for Git source discovery.

## Add a plugin

1. Copy `README_TEMPLATE.md` into a new lowercase plugin directory.
2. Add `plugin.toml` with id `jamesfeeder/<directory-name>`.
3. Add entry scripts and `translations/en.json`.
4. Add `thumbnail.webp` when a store card image is useful.
5. Run `./.tools/generate-catalog.py`.
6. Run `./.tools/check.sh`.
7. Commit the plugin and updated `catalog.toml`.

Tooling requires Python 3.11+ and no third-party packages. `check.sh` runs
offline structural validation, verifies the catalog is current, then runs
`noctalia plugins lint` for each plugin when the CLI is available.

## Useful commands

```sh
# Validate repository structure and plugin metadata
./.tools/validate.py

# Rewrite catalog.toml from all plugin manifests
./.tools/generate-catalog.py

# Validate everything without changing tracked files
./.tools/check.sh

# Build a publication-ready source tree in .dist/
./.tools/export.py
```

## TODO

- Add CI validation after local conventions stabilize.
- Add optional thumbnails for visual plugins.
