#!/bin/sh
set -e
dnf install -y golang
dnf clean all
mkdir -p /go/bin
chown -R "${_REMOTE_USER:-vscode}:root" /go
chmod -R g+rwx /go
