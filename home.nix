# SYSTEM="wsl-x11" home-manager switch --file ./home.nix --dry-run
# SYSTEM="wsl-terminal" home-manager switch --file ./home.nix --dry-run
# SYSTEM="darwin" home-manager switch --file ./home.nix --dry-run
# SYSTEM="else" home-manager switch --file ./home.nix --dry-run
# cat /home/rstauch/test.test
{
  config,
  pkgs,
  lib,
  ...
}: let
  platform = builtins.getEnv "SYSTEM";
  selectedConfig = import ./home-${platform}.nix {inherit config pkgs lib;};
in
  selectedConfig
