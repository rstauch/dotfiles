{
  pkgs,
  platform,
  ...
}: let
  extraConfig = pkgs.substituteAll {
    src = ./tmux_${platform}.conf;
  };
in {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 100500;

    # edits config, aber keine sichtbaren auswirkungen
    clock24 = true;

    newSession = true;

    # steuerung per rechter maustaste
    # paste mit shift + right click
    # umschalten zwischen tabs möglich
    mouse = true;

    shell = "${pkgs.zsh}/bin/zsh";

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
