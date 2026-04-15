#!/bin/bash

# Wrapper to run the installation test in a clean Arch Linux container

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
CONTAINER_BIN=$(command -v podman || command -v docker)

if [ -z "$CONTAINER_BIN" ]; then
    echo "Error: Neither podman nor docker found in PATH."
    exit 1
fi

echo "Using $CONTAINER_BIN to run tests..."

"$CONTAINER_BIN" run --rm \
  -v "$PROJECT_ROOT:/workspace:Z" \
  archlinux:latest \
  /bin/bash /workspace/scripts/container_install_test.sh
