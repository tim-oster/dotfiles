#!/usr/bin/env bash

set -euo pipefail

mapfile -t compose_dirs < <(find . -type f \( -name "docker-compose.yaml" -o -name "docker-compose.yml" \) -printf '%h\n' | sort -u)

if [ ${#compose_dirs[@]} -eq 0 ]; then
  echo "No docker-compose files found."
  exit 0
fi

PASSTHROUGH_ARGS=("$@")

for dir in "${compose_dirs[@]}"; do
  echo ""
  echo "Setting up: $dir"
  (
    cd "$dir"
    podman compose "${PASSTHROUGH_ARGS[@]}"
  )
done
