{
  pkgs,
  config,
  home-nix-file,
  ...
}: let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {inherit pkgs;};

  sshPrvKey = builtins.getEnv "SSH_PRV_KEY";

  java = import ./../java.nix {
    inherit pkgs;
  };

  dev = import ./../dev.nix {
    inherit pkgs;
  };

  node = import ./../node.nix {
    inherit pkgs;
  };

  broot = import ./../broot/broot.nix;
  verbs-file = builtins.toString ./../broot/verbs.hjson;

  imports = [java dev node broot];
in {
  inherit imports;

  home.file.".ssh/id_rsa".text = "${
    if sshPrvKey != null
    then sshPrvKey
    else if builtins.pathExists "${builtins.toPath "$HOME/.ssh/id_rsa"}"
    then builtins.readFile "${builtins.toPath "$HOME/.ssh/id_rsa"}"
    else ""
  }";

  # Override Nixpkgs with packages from the NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = nur;
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "22.11";

  # install global dependencies irrespective of platform
  home.packages = with pkgs; [
    htop
    bottom
    xclip
    du-dust
    openssh
    openssl
    unzip
    xz

    # A simple, fast and user-friendly alternative to find, https://github.com/sharkdp/fd
    fd

    # Side-by-side highlighted command line diffs, https://github.com/jeffkaufman/icdiff
    icdiff

    # Simplified and community-driven man pages, https://github.com/tldr-pages/tldr
    tldr

    # A utility that combines the usability of The Silver Searcher with the raw speed of grep, https://github.com/BurntSushi/ripgrep
    ripgrep
  ];

  home.username = "rstauch";
  home.language = {
    base = "de_DE.utf8";
    messages = "en_US.utf8";
  };

  home.sessionVariables = {
    TZ = "Europe/Berlin";
  };

  programs.git = {
    enable = true;
    userName = "Robert Stauch";
    userEmail = "robert.stauch@fluxdev.de";
  };

  # home-manager edit
  # TODO: home.file.config* paths might be different on mac
  home.file.".config/nixpkgs/home.nix".source = config.lib.file.mkOutOfStoreSymlink "${home-nix-file}";
  home.file.".config/home-manager/home.nix".source = config.lib.file.mkOutOfStoreSymlink "${home-nix-file}";
  home.file.".config/broot/verbs.hjson".source = config.lib.file.mkOutOfStoreSymlink "${verbs-file}";
}
