# SYSTEM="wsl-x11" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  lib,
  ...
}: let
  PROJECT_ROOT = builtins.toString ./.;

  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-wsl-x11.nix;
  };
  sharedWsl = import ./modules/shared/shared-wsl.nix {
    inherit pkgs;
    inherit lib;
    template = "wsl-x11";

    config = {username = "${shared.home.username}";};
  };
  firefox = import ./modules/firefox.nix {
    inherit pkgs;
    inherit lib;
    # template specific email to be used for firefox
    email = "project@fluxdev.de";
  };

  imports = [shared sharedWsl firefox];
in {
  inherit imports;

  home.activation = {
    # setup keepass for browser
    keepass_ini = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $HOME/.config/keepassxc
      $DRY_RUN_CMD touch $HOME/.config/keepassxc/keepassxc.ini

      # Modify Browser section
      $DRY_RUN_CMD ${pkgs.lib.getBin pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser AllowExpiredCredentials true

      $DRY_RUN_CMD ${pkgs.lib.getBin pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser CustomProxyLocation ""

      $DRY_RUN_CMD ${pkgs.lib.getBin pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser Enabled true

      # Modify Security section
      $DRY_RUN_CMD ${pkgs.lib.getBin pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Security ClearClipboardTimeout 90

      $DRY_RUN_CMD ${pkgs.lib.getBin pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Security EnableCopyOnDoubleClick true
    '';
  };

  home.packages = with pkgs; [
    google-chrome

    # jetbrains.idea-ultimate # crashes, manual install works better, see scripts/post/intellij.sh

    postman
    xdg-utils

    # libreoffice-fresh
    # Spellcheck
    # hunspell
    # hunspellDicts.de_DE
    # hunspellDicts.en_US

    # Visual diff and merge tool
    meld

    # manage ini files
    crudini
  ];

  home.sessionVariables = {
    # WSL-X11 specific
    # https://github.com/aveltras/wsl-dotfiles/blob/0fe8a104e1a096eb899475c56475a8fb33193e99/.config/nixpkgs/home.nix#L12
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0";

    XCURSOR_SIZE = 16;
    GDK_BACKEND = "x11";
    LIBGL_ALWAYS_INDIRECT = "1";
  };

  home.file = {
    # muss neu ausgeführt werden wenn sich direnv config ändert
    "setup.sh" = {
      text = ''
        #!/bin/bash
        set -e

        function clone_or_reset_repo {
            local repo_name="$1"
            local repo_url="git@ssh.dev.azure.com:v3/INGCDaaS/IngOne/$repo_name"
            local target_dir="$HOME/projects/$repo_name"

            pushd . >/dev/null

            if [ ! -d "$target_dir" ]; then
                # If the target directory doesn't exist, clone the repository
                ${pkgs.lib.getBin pkgs.git} clone "$repo_url" "$target_dir"
            else
                # If the target directory exists, fetch the latest changes from remote and reset the local branch
                cd "$target_dir"
                ${pkgs.lib.getBin pkgs.git} fetch origin
                ${pkgs.lib.getBin pkgs.git} reset --hard origin/master
            fi
            cd "$target_dir"
            mvn clean install

            popd >/dev/null
        }

        function clone_repo {
            pushd . >/dev/null

            local repo_name="$1"
            local repo_url="git@ssh.dev.azure.com:v3/INGCDaaS/IngOne/$repo_name"
            local target_dir="$HOME/projects/$repo_name"

            if [ ! -d "$target_dir" ]; then
                ${pkgs.lib.getBin pkgs.git} clone "$repo_url" "$target_dir"
            else
                echo "repo $repo_name already exists and is left untouched"
            fi

            echo "setup direnv (java11)"
            cp "${PROJECT_ROOT}/direnv/java/11/.envrc" "$target_dir"
            cp "${PROJECT_ROOT}/direnv/java/11/shell.nix" "$target_dir"

            cd "$target_dir"
            echo "direnv init..."
            ${pkgs.lib.getBin pkgs.direnv} allow

            mvn clean install -DskipTests

            echo "DONE!"
            popd >/dev/null
        }

        mkdir -p "$HOME/projects"

        clone_or_reset_repo "P03381-key-derivation-function"
        clone_or_reset_repo "P03381-cmp-client"

        clone_repo "P03381-autocert-reg-authority"
      '';
      executable = true;
    };

    "bg.sh" = {
      text = ''
        #!/bin/bash
        set -e

        # check if parameter is passed
        if [ -z "$1" ]; then
          echo "Usage: $0 <command>"
          exit 1
        fi

        # execute command with nohup in background
        nohup "$1" > /dev/null 2>&1 &
      '';
      executable = true;
    };

    "mul.sh" = {
      text = ''
        #!/bin/bash
        set -e

        # Define input variables
        APP1="$1"
        APP2="$2"

        # Check if APP2 is running
        if ! pgrep -xf "$APP2" > /dev/null; then
            # If APP2 is not running, start it
            echo "Required app $APP2 is NOT already running. Starting it now..."
            sh $HOME/bg.sh "$APP2"
        fi

        # Wait for APP2 to start
        while ! pgrep -xf "$APP2" > /dev/null; do
            sleep 1
        done

        # Start APP1 after APP2 has started
        echo "Starting main app $APP1 now..."
        sh $HOME/bg.sh "$APP1"
      '';
      executable = true;
    };
  };

  # set specific properties
  programs.git = {
    userName = pkgs.lib.mkForce "Stauch, R. (Robert)";
    userEmail = pkgs.lib.mkForce "robert.stauch.extern@ing.de";
  };
}
