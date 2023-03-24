{
  config,
  pkgs,
  lib,
  template,
  ...
}: let
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
