#!/bin/bash
sudo apt-get install -y xsel

# Get the clipboard content and assign it to a variable
ssl_private_key=$(xsel -ob)

# behelf
ssl_private_key=$(cat ~/.ssh/id_rsa)


# actual
# if [[ -z "$ssl_private_key" ]]; then
#   echo "Clipboard content is empty. Please enter the private key (use '#' on an empty line to finish):"
#   if ! read -r -d '#' ssl_private_key; then
#     echo "Failed to read private key. Exiting."
#     exit 1
#   fi
# fi

# # Exit the script if the clipboard content is empty
# if [[ -z "$ssl_private_key" ]]; then
#   echo "Clipboard content is empty. Exiting."
#   exit 1
# fi
# echo "Clipboard content is NOT empty. Continue."
### end of actual


# Add a newline to the end of the clipboard content
ssl_private_key="$ssl_private_key"$'\n'

# Set the environment variable using the clipboard content
SSH_PRV_KEY="$ssl_private_key" home-manager switch

#cd ~/test/
#rm -rf test
#git clone git@github.com:rstauch/test.git

#cat ~/.ssh/id_rsa

echo "SUCCESS"
