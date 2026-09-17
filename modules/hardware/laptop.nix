# TAbelhaNix — Laptop configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.tabelhanix.laptop {
    # Power management
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 100;
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    # Battery monitoring
    services.upower.enable = true;

    # Disable power-profiles-daemon when TLP is enabled
    services.power-profiles-daemon.enable = false;

    # Laptop specific packages
    environment.systemPackages = with pkgs; [
      pamixer
      playerctl
      pavucontrol
    ];
  };
}
