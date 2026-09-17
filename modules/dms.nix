# TAbelhaNix — DankMaterialShell configuration
{ config, pkgs, lib, ... }:

{
  # DankMaterialShell configuration
  programs.dank-material-shell = {
    enable = true;

    # System monitoring (dgop)
    enableSystemMonitoring = true;

    # VPN management
    enableVPN = true;

    # Wallpaper-based theming (matugen)
    enableDynamicTheming = true;

    # Audio visualizer (cava)
    enableAudioWavelength = true;

    # Calendar integration (khal)
    enableCalendarEvents = true;

    # Systemd service
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # Disable niri-flake's default polkit agent to avoid conflicts
  systemd.user.services.niri-flake-polkit.enable = false;
}
