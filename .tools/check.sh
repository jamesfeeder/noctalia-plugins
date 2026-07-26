#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

./.tools/validate.py
./.tools/generate-catalog.py --check

if command -v noctalia >/dev/null 2>&1; then
  for manifest in ./*/plugin.toml; do
    plugin_dir=${manifest%/plugin.toml}
    noctalia plugins lint "$plugin_dir"
  done
else
  echo "warning: noctalia CLI not found; runtime lint skipped" >&2
fi

