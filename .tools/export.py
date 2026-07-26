#!/usr/bin/env python3
"""Export the publishable plugin source into .dist."""

from __future__ import annotations

import shutil
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / ".dist"
ROOT_FILES = ("README.md", "LICENSE", "catalog.toml")
AGENT_PATHS = {"AGENTS.md", "CLAUDE.md", "CONTEXT.md", ".agents", ".codex"}


def ignore_agent_paths(_directory: str, names: list[str]) -> set[str]:
    return AGENT_PATHS.intersection(names)


def clean_output() -> None:
    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)


def remove_empty_directories() -> None:
    directories = sorted(
        (path for path in OUTPUT.rglob("*") if path.is_dir()),
        key=lambda path: len(path.parts),
        reverse=True,
    )
    for directory in directories:
        if not any(directory.iterdir()):
            directory.rmdir()


def main() -> int:
    clean_output()

    manifests = sorted(ROOT.glob("*/plugin.toml"))
    if not manifests:
        print("error: no child plugin.toml manifests found", file=sys.stderr)
        return 1

    missing = [name for name in ROOT_FILES if not (ROOT / name).is_file()]
    if missing:
        print(
            f"error: missing publishable root file(s): {', '.join(missing)}",
            file=sys.stderr,
        )
        return 1

    OUTPUT.mkdir()

    for name in ROOT_FILES:
        shutil.copy2(ROOT / name, OUTPUT / name)

    for manifest in manifests:
        plugin_dir = manifest.parent
        shutil.copytree(
            plugin_dir,
            OUTPUT / plugin_dir.name,
            ignore=ignore_agent_paths,
        )

    remove_empty_directories()
    print(f"exported {len(manifests)} plugin(s) to {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
