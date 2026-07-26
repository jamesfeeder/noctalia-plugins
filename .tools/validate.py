#!/usr/bin/env python3
"""Offline structural validation for this personal Noctalia plugin source."""

from __future__ import annotations

import json
import re
import struct
import sys
import tomllib
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
ID_PART = re.compile(r"^[a-z0-9][a-z0-9._-]*$")
SEMVER = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
    r"(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$"
)
ENTRY_TYPES = (
    "widget",
    "panel",
    "shortcut",
    "service",
    "desktop_widget",
    "launcher_provider",
)
ALLOWED_TAGS = {
    "ai", "animation", "arch", "audio", "bar", "clock", "countdown",
    "debian", "demo", "desktop", "development", "emoticon", "fedora",
    "fun", "gaming", "gentoo", "hardware", "hyprland", "indicator",
    "labwc", "language", "launcher", "mangowc", "media", "music",
    "network", "niri", "nixos", "opensuse", "panel", "privacy",
    "productivity", "recording", "service", "shortcut", "sway", "system",
    "theming", "time", "utility", "video", "void", "wallpaper",
}


class Validator:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.seen_plugin_ids: set[str] = set()

    def error(self, path: Path, message: str) -> None:
        self.errors.append(f"{path.relative_to(ROOT)}: {message}")

    def warning(self, path: Path, message: str) -> None:
        self.warnings.append(f"{path.relative_to(ROOT)}: {message}")

    def validate(self) -> int:
        manifests = sorted(ROOT.glob("*/plugin.toml"))
        if not manifests:
            self.errors.append("no top-level plugin.toml manifests found")
        for path in manifests:
            self.validate_plugin(path)
        for message in self.warnings:
            print(f"warning: {message}", file=sys.stderr)
        for message in self.errors:
            print(f"error: {message}", file=sys.stderr)
        if self.errors:
            print(f"validation failed: {len(self.errors)} error(s)", file=sys.stderr)
            return 1
        print(f"validated {len(manifests)} plugin(s)")
        return 0

    def validate_plugin(self, manifest_path: Path) -> None:
        plugin_dir = manifest_path.parent
        try:
            with manifest_path.open("rb") as file:
                manifest = tomllib.load(file)
        except (OSError, tomllib.TOMLDecodeError) as error:
            self.error(manifest_path, str(error))
            return

        required = ("id", "name", "version", "plugin_api", "author", "license", "description")
        for field in required:
            if field not in manifest:
                self.error(manifest_path, f"missing required field {field!r}")

        plugin_id = manifest.get("id")
        expected_id = f"jamesfeeder/{plugin_dir.name}"
        if plugin_id != expected_id:
            self.error(manifest_path, f"id must be {expected_id!r}")
        if isinstance(plugin_id, str):
            if plugin_id in self.seen_plugin_ids:
                self.error(manifest_path, f"duplicate plugin id {plugin_id!r}")
            self.seen_plugin_ids.add(plugin_id)
        if not ID_PART.fullmatch(plugin_dir.name):
            self.error(plugin_dir, "directory name must be lowercase plugin-id syntax")

        version = manifest.get("version")
        if not isinstance(version, str) or not SEMVER.fullmatch(version):
            self.error(manifest_path, "version must be semantic version syntax")
        plugin_api = manifest.get("plugin_api")
        if not isinstance(plugin_api, int) or isinstance(plugin_api, bool) or plugin_api < 1:
            self.error(manifest_path, "plugin_api must be a positive integer")
        if manifest.get("author") != "jamesfeeder":
            self.error(manifest_path, "author must be 'jamesfeeder'")
        description = manifest.get("description")
        if not isinstance(description, str) or not description.strip():
            self.error(manifest_path, "description must be non-empty")
        elif len(description) > 120:
            self.error(manifest_path, "description must be at most 120 characters")

        tags = manifest.get("tags", [])
        if not isinstance(tags, list) or not all(isinstance(tag, str) for tag in tags):
            self.error(manifest_path, "tags must be an array of strings")
        else:
            invalid = sorted(set(tags) - ALLOWED_TAGS)
            if invalid:
                self.error(manifest_path, f"unsupported tag(s): {', '.join(invalid)}")

        dependencies = manifest.get("dependencies", [])
        if not isinstance(dependencies, list) or not all(
            isinstance(dependency, str) and dependency for dependency in dependencies
        ):
            self.error(manifest_path, "dependencies must be an array of non-empty strings")
            dependencies = []

        readme_path = plugin_dir / "README.md"
        if not readme_path.is_file():
            self.error(readme_path, "missing plugin README")
            readme = ""
        else:
            readme = readme_path.read_text(encoding="utf-8")
            for value in (plugin_id, *dependencies):
                if isinstance(value, str) and value not in readme:
                    self.error(readme_path, f"must document {value!r}")

        license_name = manifest.get("license")
        if isinstance(license_name, str) and license_name.upper() != "MIT":
            license_path = plugin_dir / "LICENSE"
            if not license_path.is_file():
                self.error(license_path, "required for non-MIT plugin")

        translations = self.load_translations(plugin_dir / "translations" / "en.json")
        entry_ids: set[str] = set()
        for entry_type in ENTRY_TYPES:
            entries = manifest.get(entry_type, [])
            if not isinstance(entries, list):
                self.error(manifest_path, f"{entry_type} must be an array of tables")
                continue
            for entry in entries:
                if not isinstance(entry, dict):
                    self.error(manifest_path, f"{entry_type} entry must be a table")
                    continue
                entry_id = entry.get("id")
                if not isinstance(entry_id, str) or not entry_id:
                    self.error(manifest_path, f"{entry_type} entry missing id")
                elif entry_id in entry_ids:
                    self.error(manifest_path, f"duplicate entry id {entry_id!r}")
                else:
                    entry_ids.add(entry_id)
                script = entry.get("entry")
                if not isinstance(script, str) or not script:
                    self.error(manifest_path, f"{entry_type} {entry_id!r} missing entry")
                else:
                    script_path = plugin_dir / script
                    if not script_path.is_file():
                        self.error(script_path, "declared entry script does not exist")
                self.validate_translation_keys(manifest_path, entry, translations)
                settings = entry.get("setting", [])
                if isinstance(settings, list):
                    setting_keys: set[str] = set()
                    for setting in settings:
                        if not isinstance(setting, dict):
                            self.error(manifest_path, f"{entry_type} setting must be a table")
                            continue
                        key = setting.get("key")
                        if not isinstance(key, str) or not key:
                            self.error(manifest_path, f"{entry_type} setting missing key")
                        elif key in setting_keys:
                            self.error(manifest_path, f"duplicate setting key {key!r}")
                        else:
                            setting_keys.add(key)
                        self.validate_translation_keys(manifest_path, setting, translations)
                elif settings:
                    self.error(manifest_path, f"{entry_type} setting must be an array of tables")

        thumbnail = plugin_dir / "thumbnail.webp"
        if thumbnail.exists():
            try:
                dimensions = webp_dimensions(thumbnail)
            except (OSError, ValueError) as error:
                self.error(thumbnail, str(error))
            else:
                if dimensions != (960, 540):
                    self.error(thumbnail, f"must be 960x540, got {dimensions[0]}x{dimensions[1]}")

    def load_translations(self, path: Path) -> dict[str, Any]:
        if not path.is_file():
            self.error(path, "missing English translations")
            return {}
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            self.error(path, str(error))
            return {}
        if not isinstance(value, dict):
            self.error(path, "root must be an object")
            return {}
        return value

    def validate_translation_keys(
        self, manifest_path: Path, table: dict[str, Any], translations: dict[str, Any]
    ) -> None:
        for field in ("label_key", "description_key"):
            key = table.get(field)
            if key is None:
                continue
            if not isinstance(key, str) or not nested_key_exists(translations, key):
                self.error(manifest_path, f"{field} {key!r} missing from translations/en.json")


def nested_key_exists(data: dict[str, Any], dotted_key: str) -> bool:
    if isinstance(data.get(dotted_key), str):
        return True
    value: Any = data
    for part in dotted_key.split("."):
        if not isinstance(value, dict) or part not in value:
            return False
        value = value[part]
    return isinstance(value, str)


def webp_dimensions(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if len(data) < 30 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        raise ValueError("must be a WebP image")
    chunk = data[12:16]
    if chunk == b"VP8X":
        width = int.from_bytes(data[24:27], "little") + 1
        height = int.from_bytes(data[27:30], "little") + 1
        return width, height
    if chunk == b"VP8 " and data[23:26] == b"\x9d\x01\x2a":
        width, height = struct.unpack_from("<HH", data, 26)
        return width & 0x3FFF, height & 0x3FFF
    if chunk == b"VP8L" and data[20] == 0x2F:
        bits = int.from_bytes(data[21:25], "little")
        return (bits & 0x3FFF) + 1, ((bits >> 14) & 0x3FFF) + 1
    raise ValueError("unsupported or malformed WebP image")


if __name__ == "__main__":
    raise SystemExit(Validator().validate())
