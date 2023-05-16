{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first --color=auto";
  lsl = "${pkgs.lib.getExe pkgs.exa} -la --group-directories-first --color=auto --no-user --no-permissions --header --no-time";
  cls = "clear";
  c = "clear";

  tree = "${pkgs.lib.getExe pkgs.exa} --tree --level 3 --all --group-directories-first --no-permissions --no-time";
  bottom = "${pkgs.lib.getExe pkgs.bottom}";
  br = "br --cmd ':open_preview'";
  b = "bat";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD && hm-gc";
  mk = "${pkgs.lib.getExe pkgs.minikube}";
  upd = "sudo apt-get update && sudo apt-get upgrade -y";

  # run setup script as well
  # hmus = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && setup && cd $OLDPWD";

  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "${pkgs.lib.getExe pkgs.vscode} ${PROJECT_ROOT}";

  hm-gc = "nix-collect-garbage";

  # simulate mac
  pbcopy = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard";
  pbpaste = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard -o";

  # tmux
  tkill = "${pkgs.lib.getExe pkgs.tmux} kill-server";
  t = "${pkgs.lib.getExe pkgs.tmux} attach";

  # start x11 apps in background
  firefox = "sh $HOME/bg.sh '${pkgs.lib.getExe pkgs.firefox}'";
  ff = "sh $HOME/bg.sh '${pkgs.lib.getExe pkgs.firefox}'";
  # check in script ob keepass läuft, falls nicht keepass starten (wg. integration mit browser)
  # ff = "sh $HOME/mul.sh ${pkgs.lib.getExe pkgs.firefox} ${pkgs.lib.getExe pkgs.keepassxc}";

  chrome = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome-stable = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";

  postman = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.postman}";
  # keepassxc = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.keepassxc}";

  # libreoffice = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";
  # lo = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";

  idea = "fc-cache -f -v >/dev/null 2>&1 && _JAVA_OPTIONS='-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.metal=false' sh $HOME/bg.sh $HOME/idea.sh";

  os = "${pkgs.lib.getExe pkgs.onedrive} --synchronize --single-directory projects --verbose";

  meld = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.meld}";

  # setup = "$HOME/setup.sh";
}
