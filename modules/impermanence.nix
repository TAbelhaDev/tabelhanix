# TAbelhaNix — Impermanence (root on tmpfs)
{ config, lib, pkgs, impermanence, ... }:

{
  imports = [ impermanence.nixosModules.impermanence ];

  options.tabelhanix.impermanence = {
    enable = lib.mkEnableOption "root on tmpfs with persistent state";

    persistDir = lib.mkOption {
      type = lib.types.path;
      default = "/persist";
      description = "Directory for persistent state";
    };

    persistHome = lib.mkEnableOption "persist home directory";
  };

  config = lib.mkIf config.tabelhanix.impermanence.enable {
    fileSystems = {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "relatime" "mode=755" ];
      };

      "/persist" = {
        device = "/dev/disk/by-label/nixos-persist";
        fsType = "ext4";
        neededForBoot = true;
      };

      "/nix" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
        neededForBoot = true;
      };
    };

    # Persistent state directories
    environment.persistence.${toString config.tabelhanix.impermanence.persistDir} = {
      # System state
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/log"
        "/etc/NetworkManager/system-connections"
      ] ++ lib.optionals config.tabelhanix.postgresql [
        "/var/lib/postgresql"
      ] ++ lib.optionals config.tabelhanix.redis [
        "/var/lib/redis"
      ] ++ lib.optionals config.tabelhanix.vm [
        "/var/lib/libvirt"
      ];

      # User state
      users.${config.tabelhanix.username} = let
        persistHomeDirs = if config.tabelhanix.impermanence.persistHome then [
          "${config.users.users.${config.tabelhanix.username}.home}"
        ] else [];
      in {
        directories = persistHomeDirs ++ [
          # Development
          ".local/share/mise"
          ".local/share/direnv"

          # Git
          ".config/gh"

          # Neovim
          ".local/state/nvim"
          ".cache/nvim"

          # Fish
          ".config/fish"
          ".local/share/fish"

          # Tmux
          ".tmux"

          # Niri
          ".config/niri"

          # DMS
          ".config/dank-material-shell"

          # Yazi
          ".local/share/yazi"
          ".config/yazi"

          # Starship
          ".cache/starship"

          # Zoxide
          ".local/share/zoxide"

          # Browser (if installed)
          ".config/BraveSoftware"
          ".config/chromium"
          ".mozilla"

          # Other
          ".local/share/keyrings"
        ];

        files = [
          # Git
          ".gitconfig"
          ".gitignore_global"

          # Starship
          ".config/starship.toml"
        ];
      };
    };

    # Ensure persist directory exists
    systemd.tmpfiles.rules = [
      "d ${toString config.tabelhanix.impermanence.persistDir} 0755 root root -"
    ];
  };
}
