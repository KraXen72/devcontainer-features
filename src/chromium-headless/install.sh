#!/bin/sh
set -e
dnf install -y chromium-headless
dnf clean all
ln -s /usr/lib64/chromium-browser/headless_shell /usr/bin/headless_shell
