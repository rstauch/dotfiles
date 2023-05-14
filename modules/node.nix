{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    nodejs-18_x
    yarn
  ];
}
