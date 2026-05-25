#!/usr/bin/env bash
# Bootstrap script: install Nix (Determinate Systems installer) and apply
# Home Manager configuration from this flake. Safe to re-run (idempotent).

set -euo pipefail

HOST="${HOST:-mh4gf-mac}"

if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Pick up freshly installed Nix in the current shell.
  if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# Create empty stubs for secret files so the mkOutOfStoreSymlink links from
# modules/secrets.nix point at real (if empty) files. Populate these later
# with your real signingkey / API tokens.
SECRETS_DIR="$HOME/.config/secrets"
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
for f in gitconfig.local zsh_secrets; do
  if [[ ! -e "$SECRETS_DIR/$f" ]]; then
    touch "$SECRETS_DIR/$f"
    chmod 600 "$SECRETS_DIR/$f"
  fi
done

echo "==> Applying Home Manager configuration (host: ${HOST})..."
# Use the home-manager pinned by this flake (no global install required).
# -b backup preserves any pre-existing dotfiles as <name>.backup.
nix run home-manager/master -- switch --flake ".#${HOST}" -b backup

if ! command -v home-manager &>/dev/null; then
  echo "==> Installing home-manager into the user profile for everyday use..."
  nix profile install nixpkgs#home-manager
fi

echo
echo "Done. From now on, apply changes with:"
echo "  home-manager switch --flake .#${HOST}"
