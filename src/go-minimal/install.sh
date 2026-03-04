#!/bin/sh
set -e
dnf install -y golang
dnf clean all
mkdir -p /go/bin
