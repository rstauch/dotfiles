{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first";
  cls = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "${pkgs.lib.getExe pkgs.vscode} ${PROJECT_ROOT}";

  # simulate mac
  pbcopy = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard";
  pbpaste = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard -o";

  # tmux
  tkill = "${pkgs.lib.getExe pkgs.tmux} kill-server";
  t = "${pkgs.lib.getExe pkgs.tmux} attach";

  # TODO: check in script ob keepass läuft, falls nicht keepass starten (wg. integration mit browser)
  # start x11 apps in background
  firefox = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.firefox}";
  ff = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.firefox}";

  chrome = "sh $HOME/bg.sh '${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check'";
  google-chrome = "sh $HOME/bg.sh '${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check'";
  google-chrome-stable = "sh $HOME/bg.sh '${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check'";

  postman = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.postman}";
  keepassxc = "sh $HOME/bg.sh ${pkgs.lib.getExe pkgs.keepassxc}";

  libreoffice = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";
  lo = "sh $HOME/bg.sh '${pkgs.libreoffice}/bin/soffice'";

  idea = "sh $HOME/bg.sh $HOME/Downloads/intellij/idea-IU-223.8836.41/bin/idea.sh";

  os = "${pkgs.lib.getExe pkgs.onedrive} --synchronize";
}
