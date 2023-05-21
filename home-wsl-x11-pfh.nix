# SYSTEM="wsl-x11-pfh" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  lib,
  ...
}: let
  PROJECT_ROOT = builtins.toString ./.;

  gitignore-file = builtins.toString ./other/.gitignore_global;

  bgsh-file = builtins.toString ./scripts/bg.sh;
  mulsh-file = builtins.toString ./scripts/mul.sh;

  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-wsl-x11-pfh.nix;
  };
  sharedWsl = import ./modules/shared/shared-wsl.nix {
    inherit pkgs;
    inherit lib;
    template = "wsl-x11-pfh";

    config = {username = "${shared.home.username}";};
  };
  firefox = import ./modules/firefox.nix {
    inherit pkgs;
    inherit lib;
    # template specific email to be used for firefox
    email = "pfh@fluxdev.de";
  };

  imports = [shared sharedWsl firefox];
in {
  inherit imports;

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
  ];

  home.sessionVariables = {
    # WSL-X11 specific
    # https://github.com/aveltras/wsl-dotfiles/blob/0fe8a104e1a096eb899475c56475a8fb33193e99/.config/nixpkgs/home.nix#L12
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0";

    XCURSOR_SIZE = 16;
    GDK_BACKEND = "x11";
    LIBGL_ALWAYS_INDIRECT = "1";
  };

  home.file."bg.sh".source = config.lib.file.mkOutOfStoreSymlink "${bgsh-file}";
  home.file."mul.sh".source = config.lib.file.mkOutOfStoreSymlink "${mulsh-file}";

  # set specific properties
  programs.git = {
    userName = pkgs.lib.mkForce "Stauch, R. (Robert)";
    userEmail = pkgs.lib.mkForce "robert.stauch@fluxdev.de";
    extraConfig = {
      core = {
        longpaths = true;
        autocrlf = "input";
        excludesfile = "/home/" + shared.home.username + "/.gitignore_global";
      };
    };
  };

  home.file.".gitignore_global".source = config.lib.file.mkOutOfStoreSymlink "${gitignore-file}";
}
