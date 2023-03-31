{
  config,
  pkgs,
  lib,
  template,
  ...
}: let
  PROJECT_ROOT = builtins.toString ./../../.;

  custom_python_packages = python-packages:
    with python-packages; [
      numpy
      pandas
      # pip
    ];
  custom_python_enviroment = pkgs.python311.withPackages custom_python_packages;

  apply_sh_content = ''
    #!/bin/bash
    # AUTO GENERATED FILE -> DO NOT CHANGE MANUALLY
    set -e

    ssl_private_key=$(cat $HOME/.ssh/id_rsa 2>/dev/null || true)

    # Check if ssl_private_key is valid
    if ssh-keygen -y -f $HOME/.ssh/id_rsa >/dev/null 2>&1; then
      echo "Private key is valid. Proceeding..."
    else
      echo "Private key is invalid. Please ensure that $HOME/.ssh/id_rsa exists and is a valid private key."
      # Prompt the user to enter the private key
      echo "Please enter the private key (use '#' on an empty line to finish):"
      if ! read -r -d '#' ssl_private_key; then
        echo "Failed to read private key. Exiting."
        exit 1
      fi
    fi

    # Check if the private key is valid by executing ssh-keygen -y -f
    if ssh-keygen -y -f <(echo "$ssl_private_key") >/dev/null 2>&1; then
       # Add a newline to the end of the clipboard content
      ssl_private_key="$ssl_private_key"$'\n'

      # Set the environment variable using the clipboard content
      SYSTEM="${template}" SSH_PRV_KEY="$ssl_private_key" home-manager switch -b backup --file ./../home.nix

      echo "SUCCESS -> restart shell for changes to take effect"
    else
      echo "Private key is invalid. Exiting."
      exit 1
    fi
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
    "${PROJECT_ROOT}/scripts/apply.sh" = {
      text = apply_sh_content;
      executable = true;
    };
  };

  home.homeDirectory = "/home/${config.username}";

  # install dependencies shared between all wsl instances
  home.packages = with pkgs;
    [
      openssh
      onedrive

      # in order to have access to keepassxc-cli
      keepassxc

      # see https://determinate.systems/posts/nix-home-env
      direnv
      # see https://determinate.systems/posts/nix-direnv
      nix-direnv
    ]
    ++ [custom_python_enviroment];

  home.activation = {
    known_hosts = lib.hm.dag.entryAfter ["writeBoundary"] ''
       hosts=(
          "github.com"
          "gitlab.com"
          "bitbucket.org"
          "ssh.dev.azure.com"
          "vs-ssh.visualstudio.com"
       )

       mkdir -p $HOME/.ssh
       # Check if known_hosts file exists, if not create it
       if [ ! -f $HOME/.ssh/known_hosts ]; then
           touch $HOME/.ssh/known_hosts
       fi

       # Loop through the hosts array and add them to the known_hosts file if not already present
      for host in ''${hosts[@]}; do
         if ! grep -qF "$host" $HOME/.ssh/known_hosts; then
           echo "Adding $host to known_hosts file"
           $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keyscan $host >> $HOME/.ssh/known_hosts
         fi
       done
    '';
  };

  # führt ggf. zu problemen, evtl mit bash verknüpfung starten und wieder entfernen
  # systemctl --user restart onedrive.service
  # journalctl --no-pager | grep -i onedrive
  # systemctl list-unit-files --type=service
  systemd.user.services.onedrive = {
    Unit.Description = "Starting service onedrive";
    Unit.After = ["network.target"];
    Unit.ConditionPathExists = "/home/${config.username}/.config/onedrive/refresh_token";
    Service.ExecStart = "${pkgs.lib.getExe pkgs.onedrive} --monitor --single-directory projects";
    Install.WantedBy = ["default.target"];
  };
}
