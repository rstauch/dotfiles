#!/bin/bash

# https://zero-to-nix.com/start/install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix --version

nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

if ! grep -q ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" ~/.profile; then
  echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >>~/.profile
else
  echo 'The line already exists in ~/.profile'
fi

source ~/.profile
