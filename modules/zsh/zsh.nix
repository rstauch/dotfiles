{
  pkgs,
  template,
  ...
}: let
  shellAliases = import ./${template}.nix {inherit pkgs;};
in {
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    BAT_PAGER = "less -RF --mouse --wheel-lines=3";
    ZSH_TMUX_AUTOSTART = "false";
  };

  home.packages = [
    # requirements
    pkgs.xclip
    pkgs.bat
    pkgs.exa

    # fzf preview
    pkgs.lesspipe
  ];

  # history = CTRL + R
  # subdirs filesearch = CTRL + T
  # alternativ: cd ** + TAB bzw cat ** + TAB um fuzzy search zu öffnen
  # enter subdir = ALT+C
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;

    fileWidgetOptions = [
      "--height=70% --preview '${pkgs.lib.getExe pkgs.bat} --color=always --style=numbers --line-range=:1000 {}'"
    ];
  };

  # cdi = interactive, auch triggerbar mit cd xxx<SPACE><TAB>
  # cdi bla / = search from root dir
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    # would replace the cd command (doesn't work on Nushell / POSIX shells).
    options = ["--cmd cd"];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    initExtra = ''
      unsetopt BEEP
      unsetopt LIST_BEEP
      unsetopt HIST_BEEP

      unsetopt notify # Don't print status of background jobs until a prompt is about to be printed

      setopt INC_APPEND_HISTORY
      setopt globdots

      # https://github.com/Freed-Wu/fzf-tab-source
      zstyle ':fzf-tab:complete:*' fzf-min-height 1000

      # preview directory's content with exa when completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview '${pkgs.lib.getExe pkgs.exa} -1ha --color=always --group-directories-first $realpath'

      # enable preview with bat/cat/less
      zstyle ':fzf-tab:complete:(bat|cat|less):*' fzf-preview '${pkgs.lib.getExe pkgs.bat} --color=always --style=numbers --line-range=:1000 $realpath'
    '';
    autocd = true;

    shellAliases = shellAliases;
    history = {
      size = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      extended = true;
    };
    plugins = [
      {
        # Replace zsh's default completion selection menu with fzf!
        # configuration https://github.com/Aloxaf/fzf-tab#configure
        name = "fzf-tab";
        src = with pkgs;
          fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "69024c27738138d6767ea7246841fdfc6ce0d0eb";
            sha256 = "sha256-yN1qmuwWNkWHF9ujxZq2MiroeASh+KQiCLyK5ellnB8=";
          };
      }

      # überschreibt manuelle konfiguration
      # {
      #   # pre-configuration for fzf-tab
      #   # https://github.com/Freed-Wu/fzf-tab-source
      #   name = "fzf-tab-source";
      #   src = with pkgs;
      #     fetchFromGitHub {
      #       owner = "Freed-Wu";
      #       repo = "fzf-tab-source";
      #       rev = "cffe29e95512bbae172a20b6c663f626aa25590b";
      #       sha256 = "sha256-PFgDnnJX17Ec6Q+3Mw1VFv8FBtpw8SvpBtdIrWpPLdA=";
      #     };
      # }
    ];

    oh-my-zsh = {
      enable = true;
      # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
      plugins = [
        "git"

        "sudo" # press esc twice.

        # alt + left = previous dir
        # alt + right = undo
        # alt + up = parent dir
        # alt + down = first child dir
        "dirhistory"

        "colored-man-pages"

        # https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/tmux/README.md
        # ta = attach (named)
        # tad = dettach (named)
        # ts = new session (named)
        # tl = list sessions
        # tksv = terminate all
        # tkss = terminate named
        # tmux = new session
        # tmuxconf =  .tmux.conf
        "tmux"

        "zoxide"
        # 1password
        # adb
        # aws
        # gcloud
        # docker
        # docker-compose ?
        # gitflow ?
        # fzf ?
        # tmuxinator ?
      ];
      theme = "simple";
    };
  };
}
