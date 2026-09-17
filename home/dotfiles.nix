# TAbelhaNix — Dotfiles configuration for CLI tools
{ config, pkgs, lib, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting ""

      # direnv integration
      direnv hook fish | source

      # Configure fish behavior
      set -g fish_color_autosuggestion 666666
      set -g fish_color_command 00afff
      set -g fish_color_comment 990000
      set -g fish_color_cwd 00afff
      set -g fish_color_cwd_root 990000
      set -g fish_color_end 009900
      set -g fish_color_error ff0000
      set -g fish_color_escape 00a6b2
      set -g fish_color_history_current bryellow
      set -g fish_color_host normal
      set -g fish_color_host_remote 00afff
      set -g fish_color_match --background=brblue
      set -g fish_color_normal normal
      set -g fish_color_operator 00a6b2
      set -g fish_color_param 00afff
      set -g fish_color_quote 999900
      set -g fish_color_redirection 009900
      set -g fish_color_search_match bryellow --background=brblack
      set -g fish_color_selection white --bold --background=brblack
      set -g fish_color_user brgreen
      set -g fish_color_valid_path --underline
    '';
    shellAbbrs = {
      g = "git";
      gst = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gb = "git branch";
      gm = "git merge";
      gr = "git rebase";
      gstash = "git stash";
      gpop = "git stash pop";

      ls = "eza -la";
      ll = "eza -la";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      find = "fd";
      grep = "rg";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";
      vim = "nvim";
      vi = "nvim";
    };
    functions = {
      fish_greeting = "";
      mkcd = "mkdir -p $argv[1]; cd $argv[1]";
      extract = ''
        switch $argv[1]
            case "*.tar.bz2"
                tar xjf $argv[1]
            case "*.tar.gz"
                tar xzf $argv[1]
            case "*.bz2"
                bunzip2 $argv[1]
            case "*.rar"
                unrar x $argv[1]
            case "*.gz"
                gunzip $argv[1]
            case "*.tar"
                tar xf $argv[1]
            case "*.tbz2"
                tar xjf $argv[1]
            case "*.tgz"
                tar xzf $argv[1]
            case "*.zip"
                unzip $argv[1]
            case "*.Z"
                uncompress $argv[1]
            case "*.7z"
                7z x $argv[1]
            case "*"
                echo "I don't know how to extract $argv[1]"
        end
      '';
    };
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair;
      }
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf;
      }
      {
        name = "git-abbr";
        src = pkgs.fishPlugins.git-abbr;
      }
    ];
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      directory = {
        truncation_length = 3;
        style = "bold cyan";
        truncation_symbol = "…/";
      };
      git_branch = {
        style = "bold purple";
        symbol = " ";
      };
      git_status = {
        style = "bold red";
        modified = "!";
        untracked = "?";
        staged = "+";
        deleted = "✘";
      };
      git_commit = {
        style = "bold green";
      };
      nodejs = {
        style = "bold green";
        symbol = " ";
      };
      python = {
        style = "bold yellow";
        symbol = " ";
      };
      rust = {
        style = "bold red";
        symbol = " ";
      };
      go = {
        style = "bold cyan";
        symbol = " ";
      };
      docker_context = {
        style = "bold blue";
        symbol = " ";
      };
      package = {
        style = "bold green";
        symbol = " ";
      };
      nix_shell = {
        style = "bold blue";
        symbol = " ";
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "TAbelha";
    userEmail = "tabelha@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      branch.autoSetupRebase = "always";
      column.ui = "auto";
      diff.tool = "diffui";
      difftool.prompt = false;
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      status.branch = true;
      status.short = true;
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = "Dracula";
      };
    };
    ignores = [
      "*.swp"
      "*.swo"
      "*~"
      ".DS_Store"
      "Thumbs.db"
      ".direnv"
      ".env"
      "result"
    ];
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    historyLimit = 50000;
    extraConfig = ''
      # Reload config
      bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Enable vi mode
      set -g status-keys vi
      setw -g mode-keys vi

      # Vi-style copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Smart pane switching with awareness of Vim splits
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

      # Status bar
      set -g status-position bottom
      set -g status-bg colour235
      set -g status-fg colour136
      set -g status-left '#[fg=green]#S '
      set -g status-right '#[fg=yellow]%Y-%m-%d #[fg=green]%H:%M'
      set -g status-left-length 20
      set -g status-right-length 40

      # Window status
      setw -g window-status-current-style 'fg=colour166,bold'
      setw -g window-status-current-format ' #I:#W#F '
      setw -g window-status-style 'fg=colour244'
      setw -g window-status-format ' #I:#W#F '
    '';
  };

  # Mise (runtime version manager)
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      plugins = {
        erlang = "https://github.com/mise-plugins/mise-erlang";
        elixir = "https://github.com/mise-plugins/mise-elixir";
        rust = "https://github.com/mise-plugins/mise-rust";
        python = "https://github.com/mise-plugins/mise-python";
        node = "https://github.com/mise-plugins/mise-node";
        go = "https://github.com/mise-plugins/mise-go";
      };
    };
  };

  # Direnv
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_output = true;
      };
      whitelisted = {
        ".envrc" = true;
      };
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set smartindent
      set wrap
      set smartcase
      set ignorecase
      set incsearch
      set hlsearch
      set wildmenu
      set wildmode=longest:full,full
      set showmatch
      set hidden
      set nobackup
      set noswapfile
      set undofile
      set undodir=~/.vim/undodir
      set updatetime=300
      set signcolumn=yes
      set scrolloff=8
      set sidescrolloff=8
      set mouse=a
      set clipboard=unnamedplus
      set termguicolors
      set background=dark
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-fugitive
      vim-surround
      vim-repeat
      vim-commentary
      vim-eunuch
      vim-rsi
      vim-dispatch
      vim-sleuth
    ];
  };

  # Bat configuration
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "numbers,changes,header";
      italic-text = "always";
      decoration = "always";
      paging = "auto";
    };
  };

  # Eza (ls replacement)
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--info=inline"
      "--border"
      "--margin=1"
      "--padding=1"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
    historyWidgetOptions = [
      "--preview 'echo {}' --wrap"
      "--bind 'ctrl-/:toggle-preview'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -20'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  # Ripgrep
  programs.ripgrep = {
    enable = true;
  };

  # FD
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      ".direnv/"
      "node_modules/"
      "__pycache__/"
      "*.pyc"
    ];
  };

  # Bottom, dust, procs — CLI tools, not home-manager modules, install via home.packages

  # Duf (df replacement) — not available as home-manager module, install via home.packages

  # Btop
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      vim_keys = true;
    };
  };
}
