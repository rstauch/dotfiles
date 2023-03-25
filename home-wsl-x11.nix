# SYSTEM="wsl-x11" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  lib,
  ...
}: let
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
    email = "project@fluxdev.de";
  };

  imports = [shared sharedWsl firefox];
in {
  inherit imports;

  home.activation = {
    # setup keepass for browser
    keepass_ini = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Modify Browser section
      $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser AllowExpiredCredentials true

      $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser CustomProxyLocation ""

      $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Browser Enabled true

      # Modify Security section
      $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Security ClearClipboardTimeout 90

      $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.crudini} --set $HOME/.config/keepassxc/keepassxc.ini Security EnableCopyOnDoubleClick true
    '';
  };

  home.packages = with pkgs; [
    # crashes, manual install works better, see scripts/post/intellij.sh
    # jetbrains.idea-ultimate

    keepassxc
    postman
    xdg-utils

    libreoffice-fresh
    # Spellcheck
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US

    # Visual diff and merge tool
    meld

    # manage ini files
    crudini
  ];

  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;
  };

  home.sessionVariables = {
    # WSL-X11 specific
    # https://github.com/aveltras/wsl-dotfiles/blob/0fe8a104e1a096eb899475c56475a8fb33193e99/.config/nixpkgs/home.nix#L12
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0";

    XCURSOR_SIZE = 16;
    GDK_BACKEND = "x11";
    LIBGL_ALWAYS_INDIRECT = "1";
  };

  home.file = {
    "bg.sh" = {
      text = ''
        #!/bin/bash

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

        # Define input variables
         APP1="$1"
         APP2="$2"

         # Check if APP2 is running
         if ! pgrep -xf "$APP2" > /dev/null; then
             # If APP2 is not running, start it
             echo "$APP2 is not running. Starting it now..."
             sh bg.sh "$APP2"
         fi

         # Wait for APP2 to start
         while ! pgrep -xf "$APP2" > /dev/null; do
             sleep 1
         done

         # Start APP1 after APP2 has started
         echo "Starting $APP1 now..."
         sh bg.sh "$APP1"
      '';
      executable = true;
    };
  };

  # set specific properties
  # programs.git = {
  #   userName = pkgs.lib.mkForce "WSL_X11_Robert Stauch";
  #   userEmail = pkgs.lib.mkForce "WSL_X11_robert.stauch@fluxdev.de";
  # };
}
