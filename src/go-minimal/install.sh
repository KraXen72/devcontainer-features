#!/bin/sh
set -e
dnf install -y golang
dnf clean all
mkdir -p /go/bin
TARGET_USER="${_REMOTE_USER:-vscode}"
if ! id -u "${TARGET_USER}" >/dev/null 2>&1; then
	TARGET_USER="root"
fi
TARGET_GROUP="$(id -gn "${TARGET_USER}")"

chown -R "${TARGET_USER}:${TARGET_GROUP}" /go
chmod -R u+rwX,go-rwx /go
