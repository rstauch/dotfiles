# TODO: extensible machen, da vermutlich häufig benutzt !
# SYSTEM="wsl-x11" home-manager switch --file ./home.nix --dry-run
{ config, pkgs, ... }:
let
  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-wsl-x11.nix;
  };
  sharedWsl = import ./modules/shared/shared-wsl.nix {
    inherit pkgs;
    template = "wsl-x11";

    config = { username = "${shared.home.username}"; };
  };
  imports = [ shared sharedWsl ];
in {
  inherit imports;

  home.packages = with pkgs; [
    # crashes, manual install works better, see scripts/post/intellij.sh
    # jetbrains.idea-ultimate

    onedrive

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

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles.default = {

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        ublock-origin
        keepassxc-browser
      ];

      id = 0;
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "signon.rememberSignons" = false;

        # "services.sync.username" = "stefan-machmeier@outlook.com";

        # disable new-tab page
        "browser.newtabpage.enabled" = false;

        "browser.startup.homepage" = "about:blank";

        "browser.toolbars.bookmarks.visibility" = "always";

        "browser.search.openintab" = true;

        # UI
        "browser.uidensity" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.theme.content-theme" = 0;

        # privacy
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        "experiments.activeExperiment" = false;
        "experiments.enabled" = false;
        "experiments.supported" = false;
        "network.allow-experiments" = false;
      };
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
    MOZ_USE_XINPUT2 = "1";
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
