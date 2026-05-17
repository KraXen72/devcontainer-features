#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLER_URL="https://raw.githubusercontent.com/github/copilot-cli/refs/heads/main/install.sh"
PREFIX="/usr/local"
TOOLS_DIR="/usr/local/share/devcontainer-copilot-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

if [ "${AUTOUPDATE:-false}" = "true" ]; then
    if [ "$VERSION" = "latest" ] || [ "$VERSION" = "prerelease" ]; then
        mkdir -p "$TOOLS_DIR"
        touch "$TOOLS_DIR/auto-update"
    else
        echo "Warning: autoUpdate=true has no effect when version is pinned ('${VERSION}'). Auto-update will not run on container start."
    fi
fi

TARGET_USER="${_REMOTE_USER:-vscode}"
if ! id -u "${TARGET_USER}" >/dev/null 2>&1; then
    TARGET_USER="root"
fi
USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
TARGET_GROUP="$(id -gn "${TARGET_USER}")"

# Seed ownership into the image path so first-created named volumes are writable
# by the remote user when mounted over this directory at runtime.
mkdir -p "${USER_HOME}/.copilot" "$TOOLS_DIR"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.copilot"

cp "${SCRIPT_DIR}/post-start.sh" "$TOOLS_DIR/post-start.sh"
chmod +x "$TOOLS_DIR/post-start.sh"
