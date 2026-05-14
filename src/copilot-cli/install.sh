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

if [ "${AUTOUPDATE:-false}" = "true" ]; then
    if [ "$VERSION" = "latest" ] || [ "$VERSION" = "prerelease" ]; then
        mkdir -p /etc/devcontainer-copilot-cli
        touch /etc/devcontainer-copilot-cli/auto-update
    else
        echo "Warning: autoUpdate=true has no effect when version is pinned ('${VERSION}'). Auto-update will not run on container start."
    fi
fi

# Ensure ~/.copilot/settings.json exists as a regular file so Docker can
# bind-mount the host settings file onto it at container start. If it's left
# as a symlink (e.g. from a dotfiles manager) or missing, Docker will create
# a directory there instead of mounting the file, which breaks Copilot.
REMOTE_USER="${_REMOTE_USER:-vscode}"
COPILOT_DIR="/home/${REMOTE_USER}/.copilot"
SETTINGS="$COPILOT_DIR/settings.json"

mkdir -p "$COPILOT_DIR"

if [ -L "$SETTINGS" ]; then
    # Resolve through the symlink and replace with a real file.
    RESOLVED=$(readlink -f "$SETTINGS" 2>/dev/null || true)
    rm "$SETTINGS"
    if [ -n "$RESOLVED" ] && [ -f "$RESOLVED" ]; then
        cp "$RESOLVED" "$SETTINGS"
    else
        echo '{}' > "$SETTINGS"
    fi
elif [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
fi

chown -R "${REMOTE_USER}:root" "$COPILOT_DIR"
