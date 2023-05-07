#!/bin/bash
set -e

rm $HOME/.config/home-manager/home.nix* || true

# https://zero-to-nix.com/start/install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix --version

nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

if ! grep -q ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" $HOME/.profile; then
  echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >>$HOME/.profile
else
  echo 'The line already exists in $HOME/.profile'
fi

source $HOME/.profile

echo "Please enter the name of the template to be applied, ie: wsl-x11, wsl-x11-pfh (use <RETURN> to confirm):"
read -r chosen_sys
if [ -z "$chosen_sys" ]; then
  echo "No template name was provided. Exiting."
  exit 1
fi

echo "Please enter the private key (use '#' on an empty line to finish):"
if ! read -r -d '#' ssl_private_key; then
  echo "Failed to read private key. Exiting."
  exit 1
fi
ssl_private_key="$ssl_private_key"$'\n'

# Check if the private key is valid by executing ssh-keygen -y -f
if ssh-keygen -y -f <(echo "$ssl_private_key") >/dev/null 2>&1; then
  echo "Valid private key provided. Proceed with script."
else
  echo "Private key is invalid. Exiting."
  exit 1
fi

SYSTEM="$chosen_sys" SSH_PRV_KEY="$ssl_private_key" home-manager switch -b backup --file ./../home.nix

echo "SUCCESS -> restart shell for changes to take effect"

echo "attempt cleanup"
nix-collect-garbage