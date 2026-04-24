#!/usr/bin/env bash
# Populate the Julia precompile cache for VSCodeServer, which ships inside
# the julialang.language-julia extension and so can't be baked into the
# image. Runs once at container creation; the 60s cost happens here instead
# of during the first notebook cell.
set -euo pipefail

EXT_ROOT="${HOME}/.vscode-server/extensions"

# Extensions may still be installing when postCreateCommand fires; wait up
# to two minutes for the Julia extension to appear.
EXT_DIR=""
for _ in $(seq 1 120); do
  EXT_DIR=$(find "$EXT_ROOT" -maxdepth 1 -type d -name 'julialang.language-julia-*' 2>/dev/null | sort -V | tail -n 1 || true)
  if [[ -n "$EXT_DIR" && -d "$EXT_DIR/scripts/packages/VSCodeServer" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "$EXT_DIR" || ! -d "$EXT_DIR/scripts/packages/VSCodeServer" ]]; then
  echo "warm-vscodeserver: Julia extension not found under $EXT_ROOT after 2 min; skipping."
  exit 0
fi

echo "warm-vscodeserver: precompiling VSCodeServer from $EXT_DIR"
echo "warm-vscodeserver: (one-time ~60s cost; subsequent notebook cells will start fast)"

julia --project=/opt/julia-env -e "
  push!(LOAD_PATH, raw\"$EXT_DIR/scripts/packages\")
  @time \"load VSCodeServer\" using VSCodeServer
"

echo "warm-vscodeserver: done."
