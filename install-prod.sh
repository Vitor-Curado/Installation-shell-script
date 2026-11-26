#!/usr/bin/env bash

set -euo pipefail

packages=(
    nginx
    certbot
    python3-certbot-nginx
)

images=(
    "docker.io/library/postgres"
    "docker.io/grafana/grafana"
    "docker.io/victoriametrics/victoria-metrics"
    "docker.io/prom/prometheus"
    "ghcr.io/vitor-curado/vitor-curado"
)

echo "===> Updating..."

sudo dnf update -y

echo "===> Installing the juicy packages..."

sudo dnf update "${packages[@]}" -y

echo "===> Pulling the container images..."

for image in "${images[@]}"; do
    echo "  Pulling ${image}..."
    sudo docker pull "${image}"
done

echo "===> Booting the toys..."

sudo systemctl enable --now nginx

echo "===> Ist gut."