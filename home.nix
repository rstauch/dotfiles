# SSH_PRV_KEY=test home-manager switch
{ config, pkgs, ... }:

let
  # avoid collisions
  jdk11-low = pkgs.jdk11.overrideAttrs (oldAttrs: {
    meta.priority = 10;
  });

  userName = "rstauch";
  sshPrvKey = builtins.getEnv "SSH_PRV_KEY";
in
{
  # firefox extensions
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };

  home.stateVersion = "22.11";

  home.username = "${userName}";
  home.homeDirectory = "/home/${userName}";

  # deutsches zeitformat, aber englische ui
  home.language.base = "de_DE.utf8";
  home.language.messages = "en_US.utf8";

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

   programs.git = {
      enable = true;
      userName = "Robert Stauch";
      userEmail = "rober.stauch@fluxdev.de";
   };

  # https://nix-community.github.io/home-manager/options.html#opt-programs.tmux.enable
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 100500;

    # edits config, aber keine sichtbaren auswirkungen
    clock24 = true;

    newSession = true;

    # steuerung per rechter maustaste
    # paste mit shift + right click
    # umschalten zwischen tabs möglich
    mouse = true;

    shell = "${pkgs.zsh}/bin/zsh";

    # /.config/tmux/tmux.conf
    # https://man7.org/linux/man-pages/man1/tmux.1.html
    extraConfig = ''
      set-option -g update-environment "DISPLAY"
      
      # ALT+h horizontal split
      bind-key -n M-h split-window -h -c "#{pane_current_path}"
      # ALT+# horizontal split
      bind-key -n M-# split-window -h -c "#{pane_current_path}"

      # ALT+v vertical split
      bind-key -n M-v split-window -v -c "#{pane_current_path}"
      # ALT+ - (Dash/Mins) ebenfalls
      bind-key -n M-- split-window -v -c "#{pane_current_path}"

      # ALT+x to kill pane
      bind-key -n M-x kill-pane
      
      # Navigate panes using Alt+arrow keys
      bind-key -n M-Left select-pane -L
      bind-key -n M-Right select-pane -R
      bind-key -n M-Up select-pane -U
      bind-key -n M-Down select-pane -D

      # Strg+t new tab
      bind-key -n C-t new-window
      # Strg+n new tab
      bind-key -n C-n new-window

      # Strg+c close tab
      bind-key -n C-w kill-window

      # alt 1..x: access tabs (strg funzt nicht)
      bind-key -n M-1 select-window -t 1
      bind-key -n M-2 select-window -t 2
      bind-key -n M-3 select-window -t 3
      bind-key -n M-4 select-window -t 4
      bind-key -n M-5 select-window -t 5
      bind-key -n M-6 select-window -t 6
      bind-key -n M-7 select-window -t 7
      bind-key -n M-8 select-window -t 8
      bind-key -n M-9 select-window -t 9

      # zwischen windows navigieren mit strg+arrow
      bind -n C-Left previous-window
      bind -n C-Right next-window

      # ALT+D detach from session
      bind-key -n M-d detach
      # <> CTRL+D terminates session
    '';

    plugins = with pkgs; [
      # 1) shift und dann text selektieren
      # 2) dann rechte maustaste / ctrl+c um zu kopieren
      # 3) paste mit shift + right click
      # https://www.seanh.cc/2020/12/27/copy-and-paste-in-tmux/
      tmuxPlugins.yank

      # tmuxPlugins.tmux-fzf # TODO: Use fzf to manage your tmux work environment!
    ];
  };

  home.file = {
    ".ssh/id_rsa".text = "${if sshPrvKey != null then sshPrvKey else ""}";
  };

  # history = CTRL+R
  # filesearch = CTRL+T
  # alternativ: cd ** + TAB bzw cat ** + TAB um fuzzy search zu öffnen
  # subdir search = ALT+C
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  # C:\Windows\System32\wsl.exe --distribution Ubuntu-20.04 -u rstauch --cd "~" -e bash -lc zsh
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    # does not seem to work
    initExtra = ''
      unsetopt BEEP
      unsetopt LIST_BEEP
      unsetopt HIST_BEEP
    '';
    autocd = true;

    shellAliases = {
      l = "ls -lah --group-directories-first";
      cls = "clear";

      update = "cd ~ && ./apply.sh && cd $OLDPWD";

      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";

      # tmux
      tkill = "tmux kill-server";
      t = "tmux attach";

      # start x11 apps in background
      firefox = "nohup firefox > /dev/null 2>&1&";

      chrome = "nohup google-chrome-stable > /dev/null 2>&1&";
      google-chrome = "nohup google-chrome-stable > /dev/null 2>&1&";
      google-chrome-stable = "nohup google-chrome-stable > /dev/null 2>&1&";

      # auf idea ändern
      ij = "nohup idea > /dev/null 2>&1&";
      nij = "nohup idea-ultimate > /dev/null 2>&1&";

      libreoffice = "nohup libreoffice > /dev/null 2>&1&";
      postman = "nohup postman > /dev/null 2>&1&";
      keepassxc = "nohup keepassxc > /dev/null 2>&1&";
    };
    history = {
      size = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
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
      ];
      theme = "simple";
    };
  };

  # umkonfigurieren so dass ähnlich wie bei intellij die windows instanz genutzt wird (inkl. settings-sync)
  # da immer wieder crashed sobald bearbeitete dateien beim schließen nicht gespeichert werden etc.
  # evtl. für mac verwenden ?
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-azuretools.vscode-docker
      skellock.just
      jnoortheen.nix-ide
      foxundermoon.shell-format
      # disabled extensions have to be removed from vscode by hand
      #github.copilot
    ];

    userSettings = {
      "terminal.integrated.fontSize" = 14;
      "security.workspace.trust.enabled" = false;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "editor.minimap.enabled" = false;
      "update.mode" = "none";
      "window.restoreWindows" = "none";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "telemetry.telemetryLevel" = "off";
      "workbench.editorAssociations" = [
        {
          "viewType" = "vscode.markdown.preview.editor";
          "filenamePattern" = "*.md";
        }
      ];
      "keyboard.dispatch" = "keyCode";

      "window.title" = "\${activeEditorLong}";
      "editor.mouseWheelZoom" = true;
    };
    keybindings = [
      {
        key = "alt+=";
        command = "editor.action.commentLine";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "alt+o";
        command = "editor.action.formatDocument";
        when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
      }
      {
        key = "alt+l";
        command = "editor.action.formatDocument";
        when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
      }
      { key = "alt+w"; command = "editor.action.toggleWordWrap"; }
      { key = "ctrl+d"; command = "editor.action.duplicateSelection"; }

      # tut nicht
      # { key = "alt+#"; command = "workbench.action.moveEditorToRightGroup"; }
      { key = "alt+h"; command = "workbench.action.moveEditorToRightGroup"; }

      { key = "alt+-"; command = "workbench.action.moveEditorToBelowGroup"; }
      { key = "alt+v"; command = "workbench.action.moveEditorToBelowGroup"; }

      { key = "alt+d"; command = "workbench.action.moveEditorToFirstGroup"; }
      { key = "alt+x"; command = "workbench.action.closeActiveEditor"; }

      { key = "alt+up"; command = "workbench.action.focusAboveGroup"; }
      { key = "alt+down"; command = "workbench.action.focusBelowGroup"; }
      { key = "alt+left"; command = "workbench.action.focusLeftGroup"; }
      { key = "alt+right"; command = "workbench.action.focusRightGroup"; }

      { key = "alt+e"; command = "workbench.action.openRecent"; }

      { key = "alt+f"; command = "workbench.action.findInFiles"; }
      { key = "alt+f"; command = "-workbench.action.findInFiles"; }
      { key = "alt+f"; command = "workbench.action.toggleSidebarVisibility"; when = "searchViewletVisible"; }
      { key = "alt+f"; command = "-workbench.action.toggleSidebarVisibility"; when = "searchViewletVisible"; }

      { key = "alt+1"; command = "workbench.view.explorer"; }
      { key = "alt+1"; command = "-workbench.view.explorer"; }
      { key = "alt+1"; command = "workbench.action.toggleSidebarVisibility"; when = "explorerViewletVisible"; }
      { key = "alt+1"; command = "-workbench.action.toggleSidebarVisibility"; when = "explorerViewletVisible"; }

      { key = "ctrl+r"; command = "editor.action.startFindReplaceAction"; when = "editorFocus || editorIsOpen"; }
    ];
    # keybindings = (import ./apps/vscode/keybindings.nix); # https://github.com/mjstewart/nix-home-manager/blob/master/apps/vscode/keybindings.nix
  };

  home.sessionVariables = {
    # WSL specific
    # https://github.com/aveltras/wsl-dotfiles/blob/0fe8a104e1a096eb899475c56475a8fb33193e99/.config/nixpkgs/home.nix#L12
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0";

    # VSCode
    DONT_PROMPT_WSL_INSTALL = "1";
    XCURSOR_SIZE = 16;

    # OTHER
    # manage JAVA_HOME
    JAVA_HOME = "${pkgs.jdk11}/lib/openjdk";

    EDITOR = "code";
    SHELL = "${pkgs.zsh}/bin/zsh";

    ZSH_TMUX_AUTOSTART = "false";

    # bat text selection with shift
    BAT_PAGER = "less -RF --mouse --wheel-lines=3";

    GDK_BACKEND = "x11";
    LIBGL_ALWAYS_INDIRECT = "1";

    # required for intellij to work
    #_JAVA_OPTIONS = "-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.uiScale.enabled=true";
    _JAVA_OPTIONS = "-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.metal=false";
  };

  # evtl. von hand installieren und entsprechend via settings-sync login konfigurieren da ggf. in wsl mit extensions nichts funktioniert
  # sudo apt-get install firefox
  # programs.firefox = {
  #   enable = true;
  #   package = pkgs.firefox;
  #   profiles = {
  #     default = {
  #       id = 0;
  #       isDefault = true;
  #       settings = {
  #         # "browser.startup.homepage" = "https://sport1.de";
  #         "browser.shell.checkDefaultBrowser" = false;
  #         "services.sync.username" = "project@fluxdev.de";
  #         "extensions.pocket.enable" = false;
  #         # Middle click to scroll
  #         "general.autoScroll" = true;
  #         "signon.rememberSignons" = false;
  #       };
  #     };
  #   };
  # };

  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome.override {
      commandLineArgs = "--no-first-run --no-default-browser-check";
    };
  };

  home.packages = with pkgs;
    [
      fmt
      nixpkgs-fmt
      bat
      jq
      htop
      maven
      gradle
      jdk11-low
      nodejs-18_x
      yarn
      just
      keepassxc
      kubectl
      kubernetes-helm
      k9s
      terraform
      postman
      newman
      xclip
      icdiff
      tldr
      lazydocker
      gron
      fx
      q-text-as-data
      unzip
      libreoffice
      xdg-utils
      jetbrains.idea-ultimate

      # https://github.com/sharkdp/fd
			fd
			# https://github.com/charmbracelet/glow
			glow

			shellcheck
	    openssl
			ripgrep

    ];

  home.file."jdks/jdk11".source = jdk11-low;
}
