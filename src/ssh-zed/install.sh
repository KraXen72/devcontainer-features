#!/bin/sh
set -e

packages=""
if ! command -v dropbear >/dev/null 2>&1; then
    packages="${packages} dropbear"
fi
if [ ! -x /usr/libexec/openssh/sftp-server ]; then
    packages="${packages} openssh-server"
fi

if [ -n "${packages}" ]; then
    # shellcheck disable=SC2086
    dnf install -y ${packages}
    dnf clean all
fi
