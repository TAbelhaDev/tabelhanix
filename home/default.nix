# TAbelhaNix — Home Manager configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./dotfiles.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.11";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # User packages (only user-level tools, not duplicated in nixos.nix)
  home.packages = with pkgs; [
    # File managers
    yazi
    poppler-utils
    p7zip

    # Shell tools (mise for runtime management)
    mise

    # Git
    lazygit

    # Neovim
    neovim
    tree-sitter
    nodejs

    # DankMaterialShell dependencies
    quickshell
    matugen
    dgop

    # Other
    swww
    wofi
  ];

  # Niri configuration (niri-flake home module)
  # Note: DMS manages keybinds via niri.enableKeybinds and spawns itself.
  # Only input and layout settings are configured here.
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "us";
        };
      };
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
      mouse = {
        natural-scroll = false;
      };
    };
    layout = {
      gaps = 16;
      center-focused-column = "always";
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
    };
  };
}
