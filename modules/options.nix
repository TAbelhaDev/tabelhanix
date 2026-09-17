# TAbelhaNix — Custom options for the installer
{ config, lib, ... }:

{
  options.tabelhanix = {
    gpu = lib.mkOption {
      type = lib.types.enum [ "none" "intel" "amd" "nvidia" ];
      default = "none";
      description = "GPU type to configure";
    };

    laptop = lib.mkEnableOption "laptop optimizations (TLP, battery, brightness)";

    gaming = lib.mkEnableOption "gaming packages (Steam, Lutris, Gamemode, MangoHud)";

    dev = lib.mkEnableOption "development tools (compilers, containers, databases)";

    bluetooth = lib.mkEnableOption "Bluetooth support";

    vm = lib.mkEnableOption "virtualization (libvirtd, virt-manager)";

    flatpak = lib.mkEnableOption "Flatpak support";

    postgresql = lib.mkEnableOption "PostgreSQL server";

    redis = lib.mkEnableOption "Redis server";

    username = lib.mkOption {
      type = lib.types.str;
      default = "tabelha";
      description = "Primary user username";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "tabelhanix";
      description = "System hostname";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Sao_Paulo";
      description = "System timezone";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "pt_BR.UTF-8";
      description = "System locale";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Keyboard layout";
    };

    keyboardVariant = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Keyboard variant (null for default)";
    };
  };

  config = {
    networking.hostName = lib.mkDefault config.tabelhanix.hostname;
    time.timeZone = lib.mkDefault config.tabelhanix.timezone;
    i18n.defaultLocale = lib.mkDefault config.tabelhanix.locale;
  };
}
