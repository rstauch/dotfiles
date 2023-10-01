{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first --color=auto";
  lsl = "${pkgs.lib.getBin pkgs.eza} -la --group-directories-first --color=auto --no-user --no-permissions --header --no-time";
  cls = "clear";
  c = "clear";

  tree = "${pkgs.lib.getBin pkgs.eza} --tree --level 3 --all --group-directories-first --no-permissions --no-time";
  bottom = "${pkgs.lib.getBin pkgs.bottom}";
  br = "br --cmd ':open_preview'";
  b = "bat";
  e = "code";
  j = "just";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD && hm-gc";
  mk = "${pkgs.lib.getBin pkgs.minikube}";
  upd = "sudo apt-get update && sudo apt-get upgrade -y";

  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "${pkgs.lib.getBin pkgs.vscode} ${PROJECT_ROOT}";

  hm-gc = "nix-collect-garbage";

  # simulate mac
  pbcopy = "${pkgs.lib.getBin pkgs.xclip} -selection clipboard";
  pbpaste = "${pkgs.lib.getBin pkgs.xclip} -selection clipboard -o";

  # tmux
  tkill = "${pkgs.lib.getBin pkgs.tmux} kill-server";
  t = "${pkgs.lib.getBin pkgs.tmux} attach";

  # start x11 apps in background
  firefox = "sh $HOME/bg.sh '${pkgs.lib.getBin pkgs.firefox}'";
  ff = "sh $HOME/bg.sh '${pkgs.lib.getBin pkgs.firefox}'";

  chrome = "nohup ${pkgs.lib.getBin pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome = "nohup ${pkgs.lib.getBin pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome-stable = "nohup ${pkgs.lib.getBin pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";

  postman = "sh $HOME/bg.sh ${pkgs.lib.getBin pkgs.postman}";

  # libreoffice = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";
  # lo = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";

  idea = "fc-cache -f -v >/dev/null 2>&1 && _JAVA_OPTIONS='-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.metal=false' sh $HOME/bg.sh $HOME/idea.sh";

  os = "${pkgs.lib.getBin pkgs.onedrive} --synchronize --single-directory projects --verbose";

  meld = "sh $HOME/bg.sh ${pkgs.lib.getBin pkgs.meld}";
}
