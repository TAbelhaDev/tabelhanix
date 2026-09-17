# TAbelhaNix — NixOS system configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./options.nix
    ./sops.nix
    ./impermanence.nix
  ];

  # System state version
  system.stateVersion = "24.11";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Locale (extra settings)
  i18n.extraLocaleSettings = {
    LC_ADDRESS = config.tabelhanix.locale;
    LC_IDENTIFICATION = config.tabelhanix.locale;
    LC_MEASUREMENT = config.tabelhanix.locale;
    LC_MONETARY = config.tabelhanix.locale;
    LC_NAME = config.tabelhanix.locale;
    LC_NUMERIC = config.tabelhanix.locale;
    LC_PAPER = config.tabelhanix.locale;
    LC_TELEPHONE = config.tabelhanix.locale;
    LC_TIME = config.tabelhanix.locale;
  };

  # Console keyboard
  console = {
    keyMap = lib.mkDefault config.tabelhanix.keyboardLayout;
  }
  // lib.optionalAttrs (config.tabelhanix.keyboardVariant != null) {
    useXkbConfig = true;
  };

  # XDG portal for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = lib.mkDefault config.tabelhanix.bluetooth;
  services.blueman.enable = lib.mkDefault config.tabelhanix.bluetooth;

  # Graphics (base OpenGL, GPU-specific config is in modules/hardware/)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Users
  users.mutableUsers = true;
  users.users.${config.tabelhanix.username} = {
    isNormalUser = true;
    description = config.tabelhanix.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
    shell = pkgs.fish;
  };

  # System packages (core, always installed)
  environment.systemPackages =
    with pkgs;
    [
      # Core
      git
      curl
      wget
      unzip
      tree

      # CLI tools
      eza
      fd
      ripgrep
      bat
      zoxide
      jq
      wl-clipboard
      ffmpeg

      # Terminals
      foot
      alacritty

      # Shell
      fish
      starship

      # Input methods
      ibus
      ibus-engines.table
      ibus-engines.table-others
      ibus-engines.chewing
      ibus-engines.libpinyin

      # Dictionaries
      hunspell
      hunspellDicts.pt_BR
      hunspellDicts.en_US

      # Fonts
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ]
    ++ lib.optionals config.tabelhanix.dev [
      # Development
      gcc
      clang
      cmake
      ninja
      gnumake
      pkg-config
      gh
      android-tools
      ngrok
      cosign
      i2c-tools
      ddcutil
      inotify-tools
    ]
    ++ lib.optionals config.tabelhanix.gaming [
      # Gaming
      steam
      lutris
      wine
      winetricks
      gamemode
      mangohud
      gpu-screen-recorder
    ]
    ++ lib.optionals (config.tabelhanix.gpu == "nvidia") [
      # GPU tools
      openrgb
    ]
    ++ lib.optionals config.tabelhanix.laptop [
      brightnessctl
    ];

  # Services (conditional)
  services = {
    # PostgreSQL
    postgresql.enable = lib.mkDefault config.tabelhanix.postgresql;

    # Redis
    redis.servers."".enable = lib.mkDefault config.tabelhanix.redis;

    # Flatpak
    flatpak.enable = lib.mkDefault config.tabelhanix.flatpak;

    # Printing
    printing.enable = true;
    avahi.enable = true;
    avahi.openFirewall = true;
  };

  # Virtualisation
  virtualisation.libvirtd.enable = lib.mkDefault config.tabelhanix.vm;
  programs.virt-manager.enable = lib.mkDefault config.tabelhanix.vm;

  # Gaming
  programs.steam.enable = lib.mkDefault config.tabelhanix.gaming;
  programs.gamemode.enable = lib.mkDefault config.tabelhanix.gaming;

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # Fish shell
  programs.fish.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
