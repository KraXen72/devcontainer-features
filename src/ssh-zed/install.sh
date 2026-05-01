#!/bin/sh
set -e

mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/devcontainer.conf << EOF
PasswordAuthentication no
PubkeyAuthentication yes
PermitTTY yes
X11Forwarding no
AllowUsers ${_REMOTE_USER}
EOF