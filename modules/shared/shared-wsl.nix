{
  config,
  pkgs,
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
  ];
}
