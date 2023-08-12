{pkgs, ...}: let
  dictionary = [
    "builtins"
    "pkgs"
    "concat"
    "nixos"
    "nixpkgs"
  ];
in {
  getUserSettings = {
    terminal.integrated.fontSize = 14;
    security.workspace.trust.enabled = false;
    extensions.autoCheckUpdates = false;
    extensions.autoUpdate = false;
    editor.minimap.enabled = false;
    update.mode = "none";
    window.restoreWindows = "none";
    terminal.integrated.defaultProfile.linux = "zsh";
    telemetry.telemetryLevel = "off";
    workbench.editorAssociations = [
      {
        viewType = "vscode.markdown.preview.editor";
        filenamePattern = "*.md";
      }
    ];

    keyboard.dispatch = "keyCode";
    explorer.confirmDragAndDrop = false;

    window.title = "\${activeEditorLong}";
    editor.mouseWheelZoom = true;
    git.confirmSync = false;
    git.autofetch = true;
    git.branchProtection = [
      "master"
      "main"
    ];
    git.fetchOnPull = true;
    git.enableSmartCommit = true;

    git.postCommitCommand = "push";

    git.allowForcePush = true;
    git.openRepositoryInParentFolders = "always";

    editor.formatOnSave = true;
    timeline.pageOnScroll = true;

    # Copilot
    editor.inlineSuggest.enabled = true;
    github.copilot.enable = {
      "*" = true;
      yaml = true;
      plaintext = true;
      markdown = true;
    };

    "[nix]".editor.defaultFormatter = "kamadorueda.alejandra";

    nix.enableLanguageServer = true;
    nix.serverPath = pkgs.lib.getBin pkgs.nil;
    nix.serverSettings.nil = {
      formatting.command = [(pkgs.lib.getBin pkgs.alejandra)];
    };

    cSpell.languageSettings = [
      {
        languageId = "nix";
        dictionaries = ["nix"];
      }
    ];

    cSpell.customDictionaries = {
      nix = {
        path = (pkgs.writeText "dictionary-nix" (pkgs.lib.concatStringsSep "\n" dictionary)).outPath;
        description = "Extra words for the Nix language";
        scope = "user";
      };
    };

    # from: https://news.ycombinator.com/item?id=35944373
    # Disable sending telemetry
    clangd.checkUpdates = false; # Clangd
    code-runner.enableAppInsights = false; # Code Runner
    docker-explorer.enableTelemetry = false; # Docker
    extensions.ignoreRecommendations = true; # VSCode Core
    julia.enableTelemetry = false; # Julia
    kite.showWelcomeNotificationOnStartup = false; # Kite
    Lua.telemetry.enable = false; # Lua
    pros.useGoogleAnalytics = false; # PROS
    redhat.telemetry.enabled = false; # Red Hat
    rpcServer.showStartupMessage = false; # VSCode Remote Development
    sonarlint.disableTelemetry = true; # SonarLint
    telemetry.enableCrashReporter = false; # VSCode Core
    telemetry.enableTelemetry = false; # VSCode Core
    terraform.telemetry.enabled = false; # HashiCorp Terraform
    # Disable showing release notes
    gitlens.showWhatsNewAfterUpgrades = false; # GitLens
    java.help.showReleaseNotes = false; # Language Support for Java
    update.showReleaseNotes = false; # VSCode Core
    # Disable showing welcome pages / walkthroughs
    gitlens.showWelcomeOnInstall = false; # GitLens
    material-icon-theme.showWelcomeMessage = false; # Material Icon Theme
    pros.showWelcomeOnStartup = false; # PROS
    vsicons.dontShowNewVersionMessage = true; # VSCode Icons
    workbench.welcomePage.walkthroughs.openOnInstall = false; # VSCode Core
  };
}
