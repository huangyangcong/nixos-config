{ config, lib, pkgs, nixpkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
  '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));
in
{
  imports = [
    ../../home-manager/lazyvim/lazyvim.nix
  ];
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "23.05";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    # tools
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    pkgs.zoxide
    pkgs.unzip
    pkgs.zip
    pkgs.du-dust
    pkgs.openvpn
    pkgs.flameshot

    pkgs.zigpkgs.master

    pkgs.xclip # x clipboard 放在全局会导致nvim无法复制（权限问题）
    pkgs.neovim-nightly
    pkgs.sqlite

    pkgs.llvmPackages_16.llvm # to get llvm-symbolizer when clang blows up
    pkgs.clang_16
    pkgs.clang-tools_16

    #blockchain
    pkgs.cdt_3
    pkgs.leap_4

    # JavaScript / TypeScript programming language
    pkgs.deno
    pkgs.nodePackages.pnpm
    pkgs.nodePackages.yarn
    pkgs.nodejs
    pkgs.esbuild
    pkgs.k6 # Load testing: https://github.com/grafana/k6

    #python
    #pkgs.python27Full
    #pkgs.python3

    #java
    pkgs.openjdk17

    # Rust programming language
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rustfmt" ];
    })

    # Go programming language
    pkgs.go
    pkgs.gopkgs
    pkgs.gopls
    pkgs.go-tools

    #solc
    pkgs.solc

    # DevOps & Kubernetes
    # pkgs.colima # Docker on Linux on Max: Replaces Docker Desktop
    pkgs.docker-buildx
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.docker-credential-helpers # Safely store docker credentials: https://github.com/docker/docker-credential-helpers
    pkgs.docker-ls # Query docker registries https://github.com/mayflower/docker-ls
    # pkgs.dive # Analyze each layer in a Docker image - seems to be broken. Use `docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock jauderho/dive:latest ...` instead.
    pkgs.pssh # Parallel SSH
    pkgs.lnav # Log file viewer https://lnav.org/
    pkgs.minikube
    pkgs.nimbo # https://github.com/nimbo-sh/nimbo
    # pkgs.niv
    # pkgs.nixopsUnstable
    pkgs.awscli
    pkgs.cloudflared # https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/run-tunnel/trycloudflare (cloudflared tunnel --url http://localhost:7000)
    # unstable.copilot-cli # aws-copilot: https://aws.github.io/copilot-cli/docs/overview/
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubetail
    pkgs.lorri
    # pkgs.helm
    pkgs.mkcert
    pkgs.rancher
    pkgs.step-ca
    pkgs.step-cli # https://github.com/smallstep/cli
    pkgs.terraform
    pkgs.telepresence2

    (pkgs.python3.withPackages (p: with p; [
      ipython
      jupyter
    ]))
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals isLinux [
    pkgs.chromium
    pkgs.firefox
    pkgs.rofi
    pkgs.zathura
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
    LIBSQLITE =
      if isLinux then
        "${pkgs.sqlite.out}/lib/libsqlite3.so"
      else
        "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
  };

  # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile file,
  # which will override my config managed by home-manager
  # so we need to remove it before everytime we rebuild the config
  home.activation.removeExistingFcitx5Profile = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f "${config.xdg.configHome}/fcitx5/profile"
    rm -f "${config.xdg.configHome}/fcitx5/config"
  '';

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;
  home.file.".pip/pip.conf".source = ../../home-manager/python/pip.conf;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;
  xdg.configFile."devtty/config".text = builtins.readFile ./devtty;

  xdg.configFile."fcitx5/profile".text = builtins.readFile ../../home-manager/fcitx5/profile;
  xdg.configFile."fcitx5/config".text = builtins.readFile ../../home-manager/fcitx5/config;

  # Rectangle.app. This has to be imported manually using the app.
  xdg.configFile."rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;

  # tree-sitter parsers
  # xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  # xdg.configFile."nvim/queries/proto/folds.scm".source =
  #   "${sources.tree-sitter-proto}/queries/folds.scm";
  # xdg.configFile."nvim/queries/proto/highlights.scm".source =
  #   "${sources.tree-sitter-proto}/queries/highlights.scm";
  # xdg.configFile."nvim/queries/proto/textobjects.scm".source =
  #   ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  #proggnupgrams.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.direnv = {
    enable = true;

    config = {
      whitelist = {
        prefix = [
          "$HOME/code/go/src/github.com/hashicorp"
          "$HOME/code/go/src/github.com/kongkong"
        ];

        exact = [ "$HOME/.envrc" ];
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" ([
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]));

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    } // (if isLinux then {
      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    } else { });

    plugins = map
      (n: {
        name = n;
        src = sources.${n};
      }) [
      # "fish-fzf"
      "fzf.fish"
      "fish-foreign-env"
      "theme-bobthefish"
    ];
  };

  programs.lazygit = {
    enable = true;
    package = pkgs.unstable.lazygit;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          #pager = "${pkgs.delta}/bin/delta --dark --paging=never";
        };
        overrideGpg = true; #https://github.com/jesseduffield/lazygit/issues/1146
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "YangCongHuang";
    userEmail = "huangyangcong@gmail.com";
    signing = {
      key = "71DB4C11DE1F7FEB";
      signByDefault = true;
    };
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "kongkong";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "code/go";
    goPrivate = [ "github.com/kongkong" "github.com/hashicorp" "rfc822.mx" ];
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      run-shell ${sources.tmux-dracula}/dracula.tmux
    '';
  };

  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      key_bindings = [
        { key = "K"; mods = "Command"; chars = "ClearHistory"; }
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "NumpadSubtract"; mods = "Command"; action = "DecreaseFontSize"; }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = isLinux;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  # services.gpg-agent = {
  #   enable = isLinux;
  #   pinentryFlavor = "tty";
  #
  #   # cache the keys forever so we don't get asked for a password
  #   defaultCacheTtl = 31536000;
  #   maxCacheTtl = 31536000;
  # };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf isLinux {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 28;
    x11.enable = true;
  };
}
