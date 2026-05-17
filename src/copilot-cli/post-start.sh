#!/bin/bash
set -euo pipefail

TOOLS_DIR="/usr/local/share/devcontainer-copilot-cli"

TARGET_USER="${_REMOTE_USER:-vscode}"
if ! getent passwd "${TARGET_USER}" >/dev/null 2>&1; then
    TARGET_USER="$(id -un)"
fi

USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
COPILOT_HOME="${USER_HOME}/.copilot"
SETTINGS_FILE="${COPILOT_HOME}/settings.json"

if ! mkdir -p "${COPILOT_HOME}" 2>/dev/null; then
    echo "Warning: Copilot home ${COPILOT_HOME} is not writable by ${TARGET_USER}; recreate the copilot-shared volume." >&2
    exit 0
fi

if [ ! -f "${SETTINGS_FILE}" ]; then
    if ! (umask 077 && printf '{}\n' > "${SETTINGS_FILE}") 2>/dev/null; then
        echo "Warning: could not initialize ${SETTINGS_FILE}; recreate the copilot-shared volume." >&2
        exit 0
    fi
fi

if [ -f "${TOOLS_DIR}/auto-update" ]; then
    copilot update --yes 2>/dev/null || true
fi
