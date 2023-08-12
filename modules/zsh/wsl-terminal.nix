{pkgs, ...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first";
  cls = "clear";
  c = "clear";

  j = "just";

  hmu = "cd ${PROJECT_ROOT}/scripts && nix-channel --update && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  hm-gc = "nix-collect-garbage";

  # TODO: test (+dokumentieren) Verwendung with windows vscode
  # should be equivalent to hme
  dot = "${pkgs.lib.getBin pkgs.vscode} ${PROJECT_ROOT}";

  pbcopy = "${pkgs.lib.getBin pkgs.xclip} -selection clipboard";
  pbpaste = "${pkgs.lib.getBin pkgs.xclip} -selection clipboard -o";

  os = "${pkgs.lib.getBin pkgs.onedrive} --synchronize --single-directory projects --verbose";
}
