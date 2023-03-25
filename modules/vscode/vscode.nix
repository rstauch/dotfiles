{
  pkgs,
  platform,
  ...
}: let
  vscodeSettings = import ./vscode_settings.nix {inherit pkgs;};
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    userSettings = vscodeSettings.getUserSettings;
    keybindings = import ./vscode_keybindings_${platform}.nix;

    extensions = with pkgs.vscode-extensions;
      [
        ms-azuretools.vscode-docker
        skellock.just
        jnoortheen.nix-ide
        foxundermoon.shell-format
        kamadorueda.alejandra
        timonwong.shellcheck
        mhutchie.git-graph
        # disabled extensions have to be removed from vscode by hand ?
        #TODO: enable this:
        #github.copilot
      ]
      ++ (with pkgs.nur.repos.slaier.vscode-extensions; [
        ms-vscode-remote.remote-containers
      ]);
  };

  home.packages = with pkgs; [
    fmt
    nixpkgs-fmt
    alejandra
    shfmt
    shellcheck
  ];

  home.sessionVariables = {
    DONT_PROMPT_WSL_INSTALL = "1";
    EDITOR = "code";
  };
}
