#!/bin/bash
set -e

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"

if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    TARGET_USER="${_REMOTE_USER:-vscode}"
else
    TARGET_USER="${USERNAME}"
fi

user_home="$(eval echo "~${TARGET_USER}")"

if [ ! -d "$user_home" ]; then
    user_home="/root"
    TARGET_USER="root"
fi

touch "${user_home}/.bashrc"
cat "${FEATURE_DIR}/bash_theme.sh" >> "${user_home}/.bashrc"

if id -u "$TARGET_USER" > /dev/null 2>&1; then
    if [ "$USER_UID" != "automatic" ] && [ "$USER_GID" != "automatic" ]; then
        chown "$USER_UID:$USER_GID" "${user_home}/.bashrc" || true
    else
        chown "$TARGET_USER:root" "${user_home}/.bashrc" || true
    fi
fi
