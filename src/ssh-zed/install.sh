#!/bin/sh
set -e

# Generate host keys at image build time so sshd can start at runtime
# without any additional privileged steps.
ssh-keygen -A

mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/devcontainer.conf << SSHD
Port 2222
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitTTY yes
X11Forwarding no
AllowUsers ${_REMOTE_USER}
# No privilege separation: sshd runs in a single process and drops to the
# remote user via setuid(). Requires SETUID+SETGID caps in runArgs.
# No PAM: avoids AUDIT_WRITE and simplifies the cap surface further.
UsePAM no
SSHD
