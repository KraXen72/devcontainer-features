#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"
AUTO_UPDATE="${AUTOUPDATE:-true}"
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

is_exact_version() {
    [[ "$1" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([-.+][0-9A-Za-z.-]+)?$ ]]
}

echo "Installing OpenAI Codex CLI (${PACKAGE_SPEC}) with pnpm..."
mkdir -p "${PNPM_HOME_DIR}" "${PNPM_BIN_DIR}" "${USER_HOME}/.codex" "${TOOLS_DIR}"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${PNPM_HOME_DIR}" "${USER_HOME}/.codex"

install_or_update_codex "${PACKAGE_SPEC}"

if [ ! -x "${PNPM_BIN_DIR}/codex" ]; then
    echo "ERROR: ${PNPM_BIN_DIR}/codex was not found after installation."
    exit 1
fi

ln -sf "${PNPM_BIN_DIR}/codex" /usr/local/bin/codex
codex --version || true

if [ "${AUTO_UPDATE}" = "true" ]; then
    if is_exact_version "${VERSION}"; then
        echo "Warning: autoUpdate=true has no effect when version is pinned ('${VERSION}'). Auto-update will not run on container start."
        rm -f "${TOOLS_DIR}/auto-update" "${TOOLS_DIR}/package-spec"
    else
        printf '%s\n' "${PACKAGE_SPEC}" > "${TOOLS_DIR}/package-spec"
        touch "${TOOLS_DIR}/auto-update"
    fi
else
    rm -f "${TOOLS_DIR}/auto-update" "${TOOLS_DIR}/package-spec"
fi

cp "${SCRIPT_DIR}/post-start.sh" "${TOOLS_DIR}/post-start.sh"
chmod +x "${TOOLS_DIR}/post-start.sh"

echo "Done! OpenAI Codex CLI installed successfully."
