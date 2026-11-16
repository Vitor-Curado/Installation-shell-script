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
    # Development toolchain
    gcc
    gcc-c++
    gcc-aarch64-linux-gnu
    qemu-user-static
    qemu-user-binfmt

    # Development utilities
    zoxide
    nodejs
    code 
    neovim

    # LaTeX
    latexmk
    texlive-scheme-full

    # Database
    postgresql
    postgresql-server

    # Desktop applications
    steam
    brave-browser
    keepassxc
    foliate

    # Smart card infrastructure
    pcsc-lite
    pcsc-lite-ccid
    pcsc-tools
    opensc
    opensc-libs
    nss-tools
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

# ----------------
# Smart card setup
# ----------------

echo "==> Enabling PC/SC smart card service..."

sudo systemctl enable --now pcscd.socket

echo "==> Smart card infrastructure installed."
echo "    Reader diagnostics: pcsc_scan"
echo "    Card identification: opensc-tool -n"
echo "    PC/SC service: systemctl status pcscd.socket"


# ----
# Rust
# ----

echo "==> Installing Rust..."

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

source "$HOME/.cargo/env"

if ! command -v cross >/dev/null 2>&1; then
    cargo install cross
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
