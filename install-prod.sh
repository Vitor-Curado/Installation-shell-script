#!/usr/bin/env bash

set -euo pipefail

packages = (
    nginx
    certbot
    python3-certbot-nginx
)

echo "===> Updating..."

sudo dnf update -y

echo "===> Installing the juicy packages..."

sudo dnf update "${packages[@]}" -y

echo "===> Booting the toys..."

sudo systemctl enable --now nginx

echo "===> Ist gut."