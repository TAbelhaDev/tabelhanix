# TAbelhaNix — Minimal Home Manager configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager state version
  home.stateVersion = "24.11";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # User packages (minimal set)
  home.packages = with pkgs; [
    # Essential CLI tools
    git
    curl
    wget
    unzip
    tree
    eza
    fd
    ripgrep
    bat
    jq

    # Terminal
    foot

    # Shell
    fish
    starship
  ];

  # Fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
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
    };
  };

  # Git (minimal config, full config in dotfiles.nix)
  programs.git = {
    enable = true;
    userName = "TAbelha";
    userEmail = "tabelha@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Niri configuration (minimal, niri-flake home module)
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "us";
        };
      };
    };
    layout = {
      gaps = 16;
      center-focused-column = "always";
    };
  };
}
