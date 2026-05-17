#!/bin/bash
set -euo pipefail

TOOLS_DIR="/usr/local/share/devcontainer-copilot-cli"

if [ -f "${TOOLS_DIR}/auto-update" ]; then
    copilot update --yes 2>/dev/null || true
fi
