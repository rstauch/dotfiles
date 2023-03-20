# TODO: extensible machen, da vermutlich häufig benutzt !
# SYSTEM="wsl-x11" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  ...
}: let
  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-wsl-x11.nix;
  };
  sharedWsl = import ./modules/shared/shared-wsl.nix {
    inherit pkgs;
    template = "wsl-x11";

    config = {
      username = "${shared.home.username}";
    };
  };
  imports = [shared sharedWsl];
in {
  inherit imports;

  home.packages = with pkgs; [
    # crashes, manual install see scripts/intellij.sh
    # jetbrains.idea-ultimate

    onedrive

    # TODO: evtl. nicht via nix installieren ?
    firefox

    keepassxc
    postman
    xdg-utils

    libreoffice-fresh
    # Spellcheck
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
  ];

  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome.override {
      commandLineArgs = "--no-first-run --no-default-browser-check";
    };
  };

  home.sessionVariables = {
    # WSL-X11 specific
    # https://github.com/aveltras/wsl-dotfiles/blob/0fe8a104e1a096eb899475c56475a8fb33193e99/.config/nixpkgs/home.nix#L12
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0";

    XCURSOR_SIZE = 16;
    GDK_BACKEND = "x11";
    LIBGL_ALWAYS_INDIRECT = "1";

    BROWSER = "firefox";
  };

  # systemd.user.services.onedrive = {
  #   Unit.Description = "Start onedrive sync";
  #   Service.Type = "simple";
  #   Service.ExecStart = "onedrive --monitor";
  #   # Service.ExecStart = "${pkgs.onedrive} --monitor";
  #   # Install.WantedBy = ["default.target"];
  #   # Install.WantedBy = ["multi-user.target"];
  #   Install.wantedBy = ["multi-user.target"];
  #   Install.after = ["multi-user.target" "network-online.target"];
  #   # Service.Restart = "on-failure";
  #   # Service.RestartSec = 5;
  # };

  # set specific properties
  # programs.git = {
  #   userName = pkgs.lib.mkForce "WSL_X11_Robert Stauch";
  #   userEmail = pkgs.lib.mkForce "WSL_X11_robert.stauch@fluxdev.de";
  # };
}