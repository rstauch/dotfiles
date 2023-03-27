{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first";
  cls = "clear";
  c = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";

  # TODO: test (+aufschreiben) use with windows vscode
  # should be equivalent to hme
  dot = "${pkgs.lib.getExe pkgs.vscode} ${PROJECT_ROOT}";

  pbcopy = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard";
  pbpaste = "${pkgs.lib.getExe pkgs.xclip} -selection clipboard -o";

  os = "${pkgs.lib.getExe pkgs.onedrive} --synchronize --single-directory projects --verbose";
}
