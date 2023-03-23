{...}: let
  PROJECT_ROOT = builtins.toString ./../../.;
in {
  l = "ls -lah --group-directories-first";
  cls = "clear";

  hmu = "cd ${PROJECT_ROOT}/scripts && ./apply.sh && cd $OLDPWD";
  hme = "home-manager edit";
  # should be equivalent to hme
  dot = "code ${PROJECT_ROOT}";

  pbcopy = "xclip -selection clipboard";
  pbpaste = "xclip -selection clipboard -o";

  os = "onedrive --synchronize";
}
