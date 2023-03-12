#!/bin/bash

/nix/nix-installer uninstall || true

if grep -q ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" ~/.profile; then
  sed -i '/. "$HOME\/.nix-profile\/etc\/profile\.d\/hm-session-vars\.sh"/d' ~/.profile
  echo 'The line was removed from ~/.profile'
else
  echo 'The line is not in ~/.profile'
fi

# TODO: evtl. config dirs in ~/.config löschen ?