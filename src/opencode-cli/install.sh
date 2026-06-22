#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-latest}"

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

npm install -g "opencode-ai@${VERSION}"

if ! command -v opencode >/dev/null 2>&1; then
    echo "ERROR: opencode was not found in PATH after installation."
    exit 1
fi

opencode --version

VOLUME_DIR="${USER_HOME}/.opencode-shared"
mkdir -p "${VOLUME_DIR}/data" "${VOLUME_DIR}/config" "${VOLUME_DIR}/state"

# Redirect XDG directories into the persisted volume via symlinks.
# On rebuild the volume survives; container home does not.
for dir in "${USER_HOME}/.local/share/opencode" \
           "${USER_HOME}/.config/opencode" \
           "${USER_HOME}/.local/state/opencode"; do
    if [ -e "$dir" ] && [ ! -L "$dir" ]; then
        rm -rf "$dir"
    fi
    mkdir -p "$(dirname "$dir")"
done

ln -sfn "${VOLUME_DIR}/data"   "${USER_HOME}/.local/share/opencode"
ln -sfn "${VOLUME_DIR}/config" "${USER_HOME}/.config/opencode"
ln -sfn "${VOLUME_DIR}/state"  "${USER_HOME}/.local/state/opencode"

# Write yolo (auto-approve) config into the persisted config directory
cat > "${USER_HOME}/.config/opencode/opencode-yolo.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": "allow"
}
EOF

chown -R "${TARGET_USER}:${TARGET_GROUP}" "${VOLUME_DIR}"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.config/opencode"

echo "Done! OpenCode CLI installed successfully."
