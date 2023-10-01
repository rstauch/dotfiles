{
  pkgs,
  platform,
  ...
}: let
  extraConfig = pkgs.substituteAll {
    src = ./tmux_${platform}.conf;
  };
in {
  home.sessionVariables = {
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=247";
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 100000;

    # edits config, aber keine sichtbaren auswirkungen
    clock24 = true;

    newSession = true;

    # steuerung per rechter maustaste
    # paste mit shift + right click
    # umschalten zwischen tabs möglich
    mouse = true;

    shell = "${pkgs.lib.getExe pkgs.zsh}";
    terminal = "screen-256color";

    # TODO: ggf. mac spezfische Tastaturbelegung
    # https://man7.org/linux/man-pages/man1/tmux.1.html
    extraConfig = "source-file ${extraConfig}";

    plugins = with pkgs; [
      # 1) shift und dann text selektieren
      # 2) dann rechte maustaste / ctrl+c um zu kopieren
      # 3) paste mit shift + right click
      # https://www.seanh.cc/2020/12/27/copy-and-paste-in-tmux/
      tmuxPlugins.yank
    ];
  };
}
