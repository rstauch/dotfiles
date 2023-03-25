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

  imports = [java];
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
    jq
    xclip
    just
    nodejs-18_x
    yarn
    shellcheck
    openssl
    unzip
    xz

    # Make JSON greppable, https://github.com/tomnomnom/gron
    gron

    # Terminal JSON viewer, https://github.com/antonmedv/fx
    fx

    # Run SQL directly on CSV or TSV files, https://github.com/harelba/q
    q-text-as-data

    # A simple, fast and user-friendly alternative to find, https://github.com/sharkdp/fd
    fd

    # Render markdown on the CLI, https://github.com/charmbracelet/glow
    glow

    # A generic non-JVM producer and consumer for Apache Kafka, https://github.com/edenhill/kcat
    # kcat

    # A syntax-aware diff, https://github.com/Wilfred/difftastic
    # difftastic

    # CLI program that accepts piped input and presents files for selection, https://facebook.github.io/PathPicker/
    # fpp

    # A syntax-highlighting pager for git, https://github.com/dandavison/delta
    # delta

    # Side-by-side highlighted command line diffs, https://github.com/jeffkaufman/icdiff
    icdiff

    # Simplified and community-driven man pages, https://github.com/tldr-pages/tldr
    tldr

    # A utility that combines the usability of The Silver Searcher with the raw speed of grep, https://github.com/BurntSushi/ripgrep
    ripgrep

    # kubectl
    # kubernetes-helm

    # kubectx, https://github.com/ahmetb/kubectx

    # k9s
    # terraform
    # awscli2

    # newman
    # lazydocker
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
}
