{
  config,
  pkgs,
  lib,
  template,
  ...
}: let
  PROJECT_ROOT = builtins.toString ./../../.;

  apply_sh_content = ''
    #!/bin/bash
    # AUTO GENERATED FILE -> DO NOT CHANGE MANUALLY
    set -e

    # behelf
    ssl_private_key=$(cat ~/.ssh/id_rsa)

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
    SYSTEM="${template}" SSH_PRV_KEY="$ssl_private_key" home-manager switch -b backup --file ./../home.nix

    echo "SUCCESS -> restart shell for changes to take effect"
  '';

  platform = "x86_64-linux";

  vscode = import ./../vscode/vscode.nix {
    inherit pkgs;
    inherit platform;
  };

  zsh = import ./../zsh/zsh.nix {
    inherit pkgs;
    inherit platform;
    inherit template;
  };

  tmux = import ./../tmux/tmux.nix {
    inherit pkgs;
    inherit platform;
  };

  imports = [vscode zsh tmux];
in {
  inherit imports;

  # generate apply.sh programatically, reason: SYSTEM="${template}
  home.file = {
    "${PROJECT_ROOT}/scripts/apply.sh".text = apply_sh_content;
  };

  home.sessionVariables = {
  };

  home.homeDirectory = "/home/${config.username}";

  # install dependencies shared between all wsl instances
  home.packages = with pkgs; [
    openssh
  ];

  home.activation = {
    # add known hosts
    known_hosts = lib.hm.dag.entryAfter ["writeBoundary"] ''
       hosts=(
          "github.com"
          "gitlab.com"
          "bitbucket.org"
          "ssh.dev.azure.com"
          "vs-ssh.visualstudio.com"
       )

       # Check if known_hosts file exists, if not create it
       if [ ! -f ~/.ssh/known_hosts ]; then
           touch ~/.ssh/known_hosts
       fi

       # Loop through the hosts array and add them to the known_hosts file if not already present
      for host in ''${hosts[@]}; do
         if ! grep -qF "$host" ~/.ssh/known_hosts; then
           echo "Adding $host to known_hosts file"
           $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keyscan $host >> $HOME/.ssh/known_hosts
         fi
       done
    '';
  };
}
