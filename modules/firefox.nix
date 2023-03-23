{
  pkgs,
  email,
  ...
}: let
  ff_settings = {
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "signon.rememberSignons" = false;
    "signon.privateBrowsingCapture.enabled" = false;

    "services.sync.username" =
      if email != null
      then "RS  ${email}"
      else null;

    # "services.sync.username" = "RS  project@fluxdev.de";

    # disable new-tab page
    "browser.newtabpage.enabled" = false;
    "browser.newtabpage.activity-stream.default.sites" = "https://www.google.com";

    # "browser.startup.homepage" = "about:blank";
    "browser.startup.homepage" = "https://www.google.com";

    "browser.toolbars.bookmarks.visibility" = "always";

    "browser.search.openintab" = true;
    "extensions.pocket.enabled" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;

    "browser.formfill.enable" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.available" = "off";
    "extensions.formautofill.creditCards.available" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.formautofill.heuristics.enabled" = false;

    # UI
    "browser.uidensity" = 0;
    "browser.theme.toolbar-theme" = 0;
    "browser.theme.content-theme" = 0;
    "browser.uitour.enabled" = false;
    "browser.startup.page" = 3; # Restore previous session
    "browser.tabs.warnOnClose" = false;

    # disable auto update (as updates are done through nixpkgs
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
    "app.update.auto" = false;

    # disable search suggestions
    "browser.search.suggest.enabled" = false;
    "browser.search.suggest.enabled.private" = false;

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
    "beacon.enabled" = false;
    "geo.enabled" = false;
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.aboutConfig.showWarning" = false;
    "browser.aboutwelcome.enabled" = false;
    "browser.shell.checkDefaultBrowser" = false;

    "browser.uiCustomization.state" = builtins.toJSON {
      placements = {
        widget-overflow-fixed-list = [];
        unified-extensions-area = [];
        nav-bar = [
          "back-button"
          "forward-button"
          "stop-reload-button"
          "home-button"
          "urlbar-container"

          # Extensions
          "keepassxc-browser_keepassxc_org-browser-action"
          "ublock0_raymondhill_net-browser-action"
          "addon_darkreader_org-browser-action"
        ];
        toolbar-menubar = ["menubar-items"];
        TabsToolbar = [
          "firefox-view-button"
          "tabbrowser-tabs"
          "new-tab-button"
          "alltabs-button"
        ];
        PersonalToolbar = ["personal-bookmarks" "managed-bookmarks"];
      };
      seen = [
        "developer-button"
        "addon_darkreader_org-browser-action"
        "keepassxc-browser_keepassxc_org-browser-action"
        "ublock0_raymondhill_net-browser-action"
      ];
      dirtyAreaCache = [
        "nav-bar"
        "toolbar-menubar"
        "TabsToolbar"
        "PersonalToolbar"
        "unified-extensions-area"
      ];
      currentVersion = 18;
      newElementCount = 2;
    };
  };
in {
  home.sessionVariables = {
    BROWSER = "firefox";
    MOZ_USE_XINPUT2 = "1";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles.default = {
      # https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        ublock-origin
        keepassxc-browser
      ];

      id = 0;
      settings = ff_settings;
    };
  };
}
