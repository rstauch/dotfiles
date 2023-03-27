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
    nix.serverPath = pkgs.lib.getExe pkgs.nil;
    nix.serverSettings.nil = {
      formatting.command = [(pkgs.lib.getExe pkgs.alejandra)];
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
  };
}
