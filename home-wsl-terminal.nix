# SYSTEM="wsl-terminal" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  lib,
  ...
}: let
  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-wsl-terminal.nix;
  };
  sharedWsl = import ./modules/shared/shared-wsl.nix {
    inherit pkgs;
    inherit lib;
    template = "wsl-terminal";
    config = {
      username = "${shared.home.username}";
    };
  };
  imports = [shared sharedWsl];
in {
  inherit imports;

  home.packages = with pkgs; [];
}
