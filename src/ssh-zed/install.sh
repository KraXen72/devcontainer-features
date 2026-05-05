#!/bin/sh
set -e
if ! command -v dropbear >/dev/null 2>&1; then
    dnf install -y dropbear
    dnf clean all
fi
