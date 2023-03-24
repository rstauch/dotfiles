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
  firefox = "nohup ${pkgs.lib.getExe pkgs.firefox} > /dev/null 2>&1&";
  ff = "nohup ${pkgs.lib.getExe pkgs.firefox} > /dev/null 2>&1&";

  chrome = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";
  google-chrome-stable = "nohup ${pkgs.lib.getExe pkgs.google-chrome} --no-first-run --no-default-browser-check > /dev/null 2>&1&";

  postman = "nohup ${pkgs.lib.getExe pkgs.postman} > /dev/null 2>&1&";
  keepassxc = "nohup ${pkgs.lib.getExe pkgs.keepassxc} > /dev/null 2>&1&";

  libreoffice = "nohup '${pkgs.libreoffice}/bin/soffice' > /dev/null 2>&1&";
  lo = "nohup '${pkgs.libreoffice}/bin/soffice' > /dev/null 2>&1&";

  idea = "nohup $HOME/Downloads/intellij/idea-IU-223.8836.41/bin/idea.sh &";

  os = "${pkgs.lib.getExe pkgs.onedrive} --synchronize";
  osm = "nohup ${pkgs.lib.getExe pkgs.onedrive} --monitor > /dev/null 2>&1&";
}
