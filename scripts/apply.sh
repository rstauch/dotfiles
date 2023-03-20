#!/bin/bash

set -e

# behelf
# ssl_private_key=$(cat ~/.ssh/id_rsa)

### actual
if [[ -z "$ssl_private_key" ]]; then
  echo "Please enter the private key (use '#' on an empty line to finish):"
  if ! read -r -d '#' ssl_private_key; then
    echo "Failed to read private key. Exiting."
    exit 1
  fi
fi

# # Exit the script if the clipboard content is empty
if [[ -z "$ssl_private_key" ]]; then
   echo "ssl_private_key content is empty. Exiting."
   exit 1
 fi
 echo "ssl_private_key content is NOT empty. Continue."
### end of actual

# Add a newline to the end of the clipboard content
ssl_private_key="$ssl_private_key"$'\n'

# Set the environment variable using the clipboard content
SYSTEM="wsl-x11" SSH_PRV_KEY="$ssl_private_key" home-manager switch -b backup --file ./../home.nix

echo "SUCCESS -> restart shell for changes to take effect"