#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLER_URL="https://raw.githubusercontent.com/github/copilot-cli/refs/heads/main/install.sh"
PREFIX="/usr/local"

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "ERROR: curl or wget is required to install GitHub Copilot CLI."
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "ERROR: tar is required to install GitHub Copilot CLI."
    exit 1
fi

echo "Installing GitHub Copilot CLI (version: ${VERSION})..."

TMP_INSTALLER="$(mktemp)"
trap 'rm -f -- "$TMP_INSTALLER"' EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$INSTALLER_URL" -o "$TMP_INSTALLER"
else
    wget -qO "$TMP_INSTALLER" "$INSTALLER_URL"
fi

env VERSION="$VERSION" PREFIX="$PREFIX" bash "$TMP_INSTALLER"

if [ ! -x "${PREFIX}/bin/copilot" ]; then
    echo "ERROR: ${PREFIX}/bin/copilot was not found after installation."
    exit 1
fi

"${PREFIX}/bin/copilot" --version

echo "Done! GitHub Copilot CLI installed successfully."

if [ "$VERSION" = "latest" ] || [ "$VERSION" = "prerelease" ]; then
    mkdir -p /etc/devcontainer-copilot-cli
    touch /etc/devcontainer-copilot-cli/auto-update
fi
