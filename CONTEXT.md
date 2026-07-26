# Repository Context

## Purpose

This repository is James Feeder's personal source for Noctalia plugins. It is
structured for multiple independently versioned plugins and generates one
catalog consumed by Noctalia's Git source discovery.

## Domain language

| Term | Meaning |
| --- | --- |
| Plugin | One self-contained top-level directory containing `plugin.toml`. |
| Plugin id | `jamesfeeder/<directory-name>`. |
| Entry | A widget, service, panel, shortcut, desktop widget, or launcher provider declared by a plugin. |
| Catalog | Generated root `catalog.toml` containing discovery metadata from every manifest. |
| Structural validation | Offline checks for repository, manifest, translation, documentation, and optional thumbnail conventions. |
| Runtime lint | `noctalia plugins lint`, run when the Noctalia CLI is installed. |

## Invariants

- Plugin directories are future-plugin-ready and independent.
- Manifest IDs use the `jamesfeeder` namespace and match their directories.
- Plugin versions use semantic versioning.
- Every manifest label and description key resolves in `translations/en.json`.
- `catalog.toml` is generated and committed.
- Tooling has no third-party Python dependencies.
- Thumbnails are optional; present thumbnails are validated.
- Repository automation is local-only until CI is intentionally added.

