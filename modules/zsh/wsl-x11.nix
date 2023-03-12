{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first";
  cls = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "code ${PROJECT_ROOT}";

  # simulate mac
  pbcopy = "xclip -selection clipboard";
  pbpaste = "xclip -selection clipboard -o";

  # tmux
  tkill = "tmux kill-server";
  t = "tmux attach";

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

  idea = "sh ~/Downloads/intellij/idea-IU-223.8836.41/bin/idea.sh";
}
