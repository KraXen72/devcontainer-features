#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
CONFIGURE_MINIMUM_RELEASE_AGE="${CONFIGUREMINIMUMRELEASEAGE:-true}"
MINIMUM_RELEASE_AGE="${MINIMUMRELEASEAGE:-1440}"

if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: node is required but was not found in PATH."
    echo "Install Node.js first (for example with ghcr.io/devcontainers/features/node), then rebuild."
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required but was not found in PATH."
    echo "Install npm/Node.js first, then rebuild."
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

if [ "${VERSION}" = "latest" ] || [ -z "${VERSION}" ]; then
    npm install -g pnpm
else
    npm install -g "pnpm@${VERSION}"
fi

PNPM_HOME_DIR="${USER_HOME}/.local/share/pnpm"
PNPM_BIN_DIR="${PNPM_HOME_DIR}/bin"

if [ "${CONFIGURE_MINIMUM_RELEASE_AGE}" = "true" ]; then
    if ! [[ "${MINIMUM_RELEASE_AGE}" =~ ^[0-9]+$ ]]; then
        echo "ERROR: minimumReleaseAge must be an integer number of minutes. Got: ${MINIMUM_RELEASE_AGE}"
        exit 1
    fi
    su - "${TARGET_USER}" -c "export PNPM_HOME='${PNPM_HOME_DIR}'; export PATH='${PNPM_BIN_DIR}:${PNPM_HOME_DIR}':\$PATH; $(printf 'pnpm config set minimumReleaseAge %q --global' "${MINIMUM_RELEASE_AGE}")"
fi

# Single-quoted heredoc: ${HOME}, ${PNPM_HOME}, ${PATH} expand at shell startup
# inside the container, not at install time. Covers both v10 (globals in PNPM_HOME)
# and v11 (globals in PNPM_HOME/bin). Store defaults to PNPM_HOME/store on both.
cat > /etc/profile.d/pnpm.sh << 'EOF'
export PNPM_HOME="${HOME}/.local/share/pnpm"
export PATH="${PNPM_HOME}/bin:${PNPM_HOME}:${PATH}"
EOF
chmod +x /etc/profile.d/pnpm.sh

echo "Done! pnpm installed and configured for ${TARGET_USER}."
