#!/bin/bash

set -e

SYSTEM="wsl-x11" home-manager switch --file ./../home.nix --dry-run
SYSTEM="wsl-x11-pfh" home-manager switch --file ./../home.nix --dry-run
SYSTEM="wsl-terminal" home-manager switch --file ./../home.nix --dry-run
SYSTEM="darwin" home-manager switch --file ./../home.nix --dry-run

./apply.sh
