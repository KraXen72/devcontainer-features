#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"

if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required but was not found in PATH."
    exit 1
fi

npm install -g "opencode-ai@${VERSION}"

if ! command -v opencode >/dev/null 2>&1; then
    echo "ERROR: opencode was not found in PATH after installation."
    exit 1
fi
