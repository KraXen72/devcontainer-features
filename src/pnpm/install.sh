#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
CONFIGURE_MINIMUM_RELEASE_AGE="${CONFIGUREMINIMUMRELEASEAGE:-true}"
MINIMUM_RELEASE_AGE="${MINIMUMRELEASEAGE:-1440}"
STORE_DIR_RAW="${STOREDIR:-~/.pnpm-store}"

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

if [ "${STORE_DIR_RAW}" = "~" ]; then
    STORE_DIR="${USER_HOME}"
elif [[ "${STORE_DIR_RAW}" == ~/* ]]; then
    STORE_DIR="${USER_HOME}/${STORE_DIR_RAW#~/}"
else
    STORE_DIR="${STORE_DIR_RAW}"
fi

if [[ "${STORE_DIR}" != /* ]]; then
    echo "ERROR: storeDir must be an absolute path or start with '~/'. Got: ${STORE_DIR_RAW}"
    exit 1
fi

if [ "${STORE_DIR}" != "/pnpm-store" ] && [[ "${STORE_DIR}" != "${USER_HOME}"/* ]]; then
    echo "ERROR: storeDir must be '/pnpm-store' or be inside ${USER_HOME}. Got: ${STORE_DIR}"
    exit 1
fi

if [ "${VERSION}" = "latest" ] || [ -z "${VERSION}" ]; then
    npm install -g pnpm
else
    npm install -g "pnpm@${VERSION}"
fi

mkdir -p /pnpm-store
chown -R "${TARGET_USER}:root" /pnpm-store || true

if [ "${STORE_DIR}" != "/pnpm-store" ]; then
    mkdir -p "$(dirname "${STORE_DIR}")"
    if [ -e "${STORE_DIR}" ] && [ ! -L "${STORE_DIR}" ]; then
        echo "ERROR: storeDir already exists and is not a symlink: ${STORE_DIR}"
        echo "Refusing to replace existing paths for safety."
        exit 1
    fi
    ln -sfn /pnpm-store "${STORE_DIR}"
fi

if [ "${CONFIGURE_MINIMUM_RELEASE_AGE}" = "true" ]; then
    if ! [[ "${MINIMUM_RELEASE_AGE}" =~ ^[0-9]+$ ]]; then
        echo "ERROR: minimumReleaseAge must be an integer number of minutes. Got: ${MINIMUM_RELEASE_AGE}"
        exit 1
    fi
    su - "${TARGET_USER}" -c "$(printf 'pnpm config set minimumReleaseAge %q --global' "${MINIMUM_RELEASE_AGE}")"
fi

su - "${TARGET_USER}" -c "$(printf 'pnpm config set store-dir %q --global' "${STORE_DIR}")"

echo "Done! pnpm installed and configured for ${TARGET_USER}."

