#!/bin/sh
set -e
dnf install -y chromium-headless
dnf clean all
