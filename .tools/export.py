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


def main() -> int:
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

    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)
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

    print(f"exported {len(manifests)} plugin(s) to {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
