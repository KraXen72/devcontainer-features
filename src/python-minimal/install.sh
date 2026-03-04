#!/bin/sh
set -e

VERSION="${VERSION:-"latest"}"

if [ "$VERSION" = "latest" ]; then
    PKG="python3"
else
    PKG="python${VERSION}"
fi

dnf install -y "$PKG" "${PKG}-pip" python-unversioned-command
dnf clean all
