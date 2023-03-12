# SYSTEM="darwin" home-manager switch --file ./home.nix --dry-run
{
  config,
  pkgs,
  ...
}: let
  shared = import ./modules/shared/shared.nix {
    inherit pkgs;
    inherit config;
    home-nix-file = builtins.toString ./home-darwin.nix;
  };
in {
  imports = [shared];

  # TODO: change this
  home.homeDirectory = "/home/${shared.home.username}";

  home.packages = [];
}
