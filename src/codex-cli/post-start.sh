#!/bin/bash
set -euo pipefail

TOOLS_DIR="/usr/local/share/devcontainer-codex-cli"

TARGET_USER="${_REMOTE_USER:-vscode}"
if ! getent passwd "${TARGET_USER}" >/dev/null 2>&1; then
    TARGET_USER="$(id -un)"
fi

USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
CODEX_HOME="${USER_HOME}/.codex"
PNPM_HOME_DIR="${USER_HOME}/.local/share/pnpm"
PNPM_BIN_DIR="${PNPM_HOME_DIR}/bin"

run_as_target_user() {
    local command="$1"
    if [ "$(id -u)" = "$(id -u "${TARGET_USER}")" ]; then
        bash -lc "${command}"
    elif [ "$(id -u)" = "0" ]; then
        su - "${TARGET_USER}" -c "${command}"
    else
        bash -lc "${command}"
    fi
}

auto_update_codex() {
    if [ ! -f "${TOOLS_DIR}/auto-update" ] || [ ! -f "${TOOLS_DIR}/package-spec" ]; then
        return
    fi

    local spec
    local quoted_spec
    spec="$(cat "${TOOLS_DIR}/package-spec")"
    quoted_spec="$(printf '%q' "${spec}")"

    run_as_target_user "export PNPM_HOME='${PNPM_HOME_DIR}'; export PATH='${PNPM_BIN_DIR}:${PNPM_HOME_DIR}':\$PATH; pnpm add --global ${quoted_spec} >/dev/null"
}

mkdir -p "${CODEX_HOME}"
auto_update_codex || true
