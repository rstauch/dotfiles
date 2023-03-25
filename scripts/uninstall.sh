#!/bin/bash

/nix/nix-installer uninstall || true

if grep -q ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" $HOME/.profile; then
  sed -i '/. "$HOME\/.nix-profile\/etc\/profile\.d\/hm-session-vars\.sh"/d' $HOME/.profile
  echo 'The line was removed from $HOME/.profile'
else
  echo 'The line is not in $HOME/.profile'
fi

# TODO: evtl. config dirs in $HOME/.config löschen ?
