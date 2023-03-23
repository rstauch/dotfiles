{...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  # TODO: use pkgs.lib.getExe pkgs.bat instead of postman etc
  l = "ls -lah --group-directories-first";
  cls = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "code ${PROJECT_ROOT}";

  pbcopy = "xclip -selection clipboard";
  pbpaste = "xclip -selection clipboard -o";

  os = "onedrive --synchronize";
  osm = "nohup onedrive --monitor > /dev/null 2>&1&";
}
