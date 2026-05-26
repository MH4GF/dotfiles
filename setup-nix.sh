#!/usr/bin/env bash

set -euo pipefail

HOST="${HOST:-mh4gf-mac}"

if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

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
nix run home-manager/master -- switch --flake ".#${HOST}" -b backup

if ! command -v home-manager &>/dev/null; then
  echo "==> Installing home-manager into the user profile for everyday use..."
  nix profile install nixpkgs#home-manager
fi

if command -v gpgconf &>/dev/null; then
  echo "==> Restarting gpg-agent to pick up new pinentry path..."
  gpgconf --kill gpg-agent || true
fi

echo
echo "Done. From now on, apply changes with:"
echo "  home-manager switch --flake .#${HOST}"
