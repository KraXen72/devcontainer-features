#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"
PACKAGE="@openai/codex"
PACKAGE_SPEC="${PACKAGE}@${VERSION}"
TOOLS_DIR="/usr/local/share/devcontainer-codex-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required but was not found in PATH."
    exit 1
fi

TARGET_USER="${_REMOTE_USER:-vscode}"
if ! [[ "${TARGET_USER}" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    echo "ERROR: invalid remote user '${TARGET_USER}'."
    exit 1
fi

USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
if [ -z "${USER_HOME}" ] || [ ! -d "${USER_HOME}" ]; then
    TARGET_USER="root"
    USER_HOME="/root"
fi
TARGET_GROUP="$(id -gn "${TARGET_USER}")"

echo "Installing OpenAI Codex CLI (${PACKAGE_SPEC}) with npm..."
npm install --global "${PACKAGE_SPEC}"

if ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: codex was not found in PATH after installation."
    exit 1
fi

codex --version

mkdir -p "${USER_HOME}/.codex" "${TOOLS_DIR}"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.codex"

CONFIG_SOURCE="${SCRIPT_DIR}/config-overrride.toml"
FINAL_CONFIG="$(cat "${CONFIG_SOURCE}")"
if [ -n "${CONFIGOVERRIDE:-}" ]; then
    FINAL_CONFIG="${FINAL_CONFIG}"$'\n'"${CONFIGOVERRIDE}"
fi
printf '%s\n' "${FINAL_CONFIG}" > "${USER_HOME}/.codex/config.toml"
chown "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.codex/config.toml"
cp "${USER_HOME}/.codex/config.toml" "${TOOLS_DIR}/codex-config.toml"

echo "Done! OpenAI Codex CLI installed successfully."
