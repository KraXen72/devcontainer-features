#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"
PACKAGE="@openai/codex"
TOOLS_DIR="/usr/local/share/devcontainer-codex-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v pnpm >/dev/null 2>&1; then
    echo "ERROR: pnpm is required but was not found in PATH."
    echo "Install the pnpm devcontainer feature before codex-cli, then rebuild."
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

PNPM_HOME_DIR="${USER_HOME}/.local/share/pnpm"
PNPM_BIN_DIR="${PNPM_HOME_DIR}/bin"
PACKAGE_SPEC="${PACKAGE}@${VERSION}"

run_as_target_user() {
    local command="$1"
    if [ "${TARGET_USER}" = "root" ]; then
        bash -lc "${command}"
    else
        su - "${TARGET_USER}" -c "${command}"
    fi
}

install_or_update_codex() {
    local spec="$1"
    local quoted_spec
    quoted_spec="$(printf '%q' "${spec}")"
    run_as_target_user "export PNPM_HOME='${PNPM_HOME_DIR}'; export PATH='${PNPM_BIN_DIR}:${PNPM_HOME_DIR}':\$PATH; pnpm add --global ${quoted_spec}"
}

echo "Installing OpenAI Codex CLI (${PACKAGE_SPEC}) with pnpm..."
mkdir -p "${PNPM_HOME_DIR}" "${PNPM_BIN_DIR}" "${USER_HOME}/.codex"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${PNPM_HOME_DIR}" "${USER_HOME}/.codex"

rm -f "${PNPM_BIN_DIR}/codex"
install_or_update_codex "${PACKAGE_SPEC}"

if [ ! -x "${PNPM_BIN_DIR}/codex" ]; then
    echo "ERROR: ${PNPM_BIN_DIR}/codex was not found after installation."
    exit 1
fi

ln -sf "${PNPM_BIN_DIR}/codex" /usr/local/bin/codex
run_as_target_user "export PNPM_HOME='${PNPM_HOME_DIR}'; export PATH='${PNPM_BIN_DIR}:${PNPM_HOME_DIR}':\$PATH; codex --version"

CONFIG_SOURCE="${SCRIPT_DIR}/config-overrride.toml"
FINAL_CONFIG="$(cat "${CONFIG_SOURCE}")"
if [ -n "${CONFIGOVERRIDE:-}" ]; then
    FINAL_CONFIG="${FINAL_CONFIG}"$'\n'"${CONFIGOVERRIDE}"
fi
printf '%s\n' "${FINAL_CONFIG}" > "${USER_HOME}/.codex/config.toml"
chown "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.codex/config.toml"
mkdir -p "${TOOLS_DIR}"
cp "${USER_HOME}/.codex/config.toml" "${TOOLS_DIR}/codex-config.toml"

echo "Done! OpenAI Codex CLI installed successfully."
