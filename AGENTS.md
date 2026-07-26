# Agent Guide

## Repository

This is a personal, multi-plugin Noctalia source. Each top-level plugin
directory is self-contained. Read `CONTEXT.md` for repository concepts and the
target plugin's `AGENTS.md` and `CONTEXT.md` before changing plugin behavior.

## Layout

- `<plugin>/plugin.toml` — plugin manifest
- `<plugin>/README.md` — user-facing plugin documentation
- `<plugin>/translations/en.json` — English manifest strings
- `<plugin>/AGENTS.md` — plugin-specific engineering rules
- `<plugin>/CONTEXT.md` — plugin domain model, when useful
- `.tools/` — repository validation and catalog generation
- `catalog.toml` — generated source catalog; commit it

Plugin directory names must match the suffix of
`jamesfeeder/<plugin-directory>`.

## Development

Run all local checks:

```sh
./.tools/check.sh
```

Regenerate the catalog after manifest changes:

```sh
./.tools/generate-catalog.py
```

Tooling uses Python 3.11+ standard library only. Thumbnails are optional. When
present, they must be 960×540 WebP files named `thumbnail.webp`.

## Agent skills

### Issue tracker

Issues use local Markdown under `.scratch/`. See
`docs/agents/issue-tracker.md`.

### Triage labels

Use the standard local triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

See `docs/agents/domain.md` for routing between repository and plugin contexts.

