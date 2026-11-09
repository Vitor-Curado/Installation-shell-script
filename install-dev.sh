#!/usr/bin/env bash

set -euo pipefail

# -------------
# Configuration
# -------------

RPM_REPOS=(
    "https://packages.microsoft.com/yumrepos/vscode/config.repo"
    "https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
)

PACKAGES=(
    gcc
    gcc-c++
    gcc-aarch64-linux-gnu
    qemu-user-static
    zoxide
    nodejs
    code 
    neovim
    postgresql
    postgresql-server
    steam
    brave-browser
    copyq
    keepassxc
    foliate
)

# ------
# System
# ------

echo "==> Updating..."
sudo dnf update -y

echo "==> Installing dnf-plugins-core..."
sudo dnf install -y dnf-plugins-core

# ------------
# Repositories
# ------------

echo "==> Adding RPM repositories..."
for repo in "${RPM_REPOS[@]}"; do
    sudo dnf config-manager addrepo --from-repofile="$repo"
done

# --------
# Packages
# --------

echo "==> Installing packages..."
sudo dnf install -y "${PACKAGES[@]}"

# ----
# Rust
# ----

echo "==> Installing Rust..."

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# ----------
# PostgreSQL
# ----------

if [ ! -d /var/lib/pgsql/data/base ]; then
    echo "==> Initializing PostgreSQL database..."
    sudo postgresql-setup --initdb
fi

echo "==> Enabling PostgreSQL service..."
sudo systemctl enable --now postgresql

echo "==> Done!"
