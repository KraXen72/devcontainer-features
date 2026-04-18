#!/bin/bash
set -e

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USERNAME="${USERNAME:-automatic}"
USER_UID="${USERUID:-automatic}"
USER_GID="${USERGID:-automatic}"

if [[ "$USERNAME" == auto || "$USERNAME" == automatic ]]; then
    TARGET_USER="${_REMOTE_USER:-vscode}"
else
    TARGET_USER="$USERNAME"
fi

[[ "$TARGET_USER" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || { echo "ERROR: invalid username '$TARGET_USER'."; exit 1; }

user_home="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [[ -z "$user_home" || ! -d "$user_home" ]]; then
    user_home=/root
    TARGET_USER=root
fi

rc="$user_home/.bashrc"
start="# >>> common-utils-bash-prompt >>>"
end="# <<< common-utils-bash-prompt <<<"

touch "$rc"
tmp="$(mktemp)"
awk -v s="$start" -v e="$end" '
    $0==s {skip=1; next}
    $0==e {skip=0; next}
    !skip {print}
' "$rc" > "$tmp"
mv "$tmp" "$rc"

{
    echo "$start"
    cat "$FEATURE_DIR/bash_theme.sh"
    echo "$end"
} >> "$rc"

if id -u "$TARGET_USER" >/dev/null 2>&1; then
    if [[ "$USER_UID" != automatic && "$USER_GID" != automatic ]]; then
        chown "$USER_UID:$USER_GID" "$rc" || true
    else
        chown "$TARGET_USER:root" "$rc" || true
    fi
fi
