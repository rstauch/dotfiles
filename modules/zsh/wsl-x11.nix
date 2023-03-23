{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  # TODO: use pkgs.lib.getExe pkgs.bat instead of postman etc

  l = "ls -lah --group-directories-first";
  cls = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "code ${PROJECT_ROOT}";

  # simulate mac
  pbcopy = "xclip -selection clipboard";
  pbpaste = "xclip -selection clipboard -o";

  # tmux
  tkill = "tmux kill-server";
  t = "tmux attach";

  # TODO: check in script ob keepass läuft, falls nicht keepass starten (wg. integration mit browser)
  # start x11 apps in background
  firefox = "nohup firefox > /dev/null 2>&1&";
  ff = "nohup firefox > /dev/null 2>&1&";

  chrome = "nohup google-chrome-stable > /dev/null 2>&1&";
  google-chrome = "nohup google-chrome-stable > /dev/null 2>&1&";
  google-chrome-stable = "nohup google-chrome-stable > /dev/null 2>&1&";

  postman = "nohup postman > /dev/null 2>&1&";
  keepassxc = "nohup keepassxc > /dev/null 2>&1&";

  libreoffice = "nohup '${pkgs.libreoffice}/bin/soffice' > /dev/null 2>&1&";
  lo = "nohup '${pkgs.libreoffice}/bin/soffice' > /dev/null 2>&1&";

  # TODO: test: nohup ~/Downloads/intellij/idea-IU-223.8836.41/bin/idea.sh &
  idea = "sh ~/Downloads/intellij/idea-IU-223.8836.41/bin/idea.sh";

  os = "onedrive --synchronize";
  osm = "nohup onedrive --monitor > /dev/null 2>&1&";
}
