# TAbelhaNix — NVIDIA Optimus/PRIME configuration
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.tabelhanix.nvidia or { };
in
{
  options.tabelhanix.nvidia = {
    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:0:2:0";
      description = "Intel iGPU PCI bus ID for PRIME";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "NVIDIA dGPU PCI bus ID for PRIME";
    };

    prime = lib.mkOption {
      type = lib.types.enum [
        "offload"
        "sync"
        "reverse-sync"
      ];
      default = "offload";
      description = "PRIME mode: offload (switch GPUs), sync (both active), reverse-sync (dGPU renders for iGPU)";
    };
  };

  config = lib.mkIf (config.tabelhanix.gpu == "nvidia") {
    # NVIDIA driver
    hardware.nvidia = {
      # Use open-source kernel module
      open = true;

      # Enable modesetting
      modesetting.enable = true;

      # Enable power management
      powerManagement = {
        enable = true;
        finegrained = true;
      };

      # Prime configuration
      prime = {
        offload = {
          enable = lib.mkDefault (cfg.prime == "offload");
          enableOffloadCmd = lib.mkDefault (cfg.prime == "offload");
        };
        sync.enable = lib.mkDefault (cfg.prime == "sync");
        reverseSync.enable = lib.mkDefault (cfg.prime == "reverse-sync");

        intelBusId = cfg.intelBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };

      # NVIDIA settings GUI
      nvidiaSettings = true;

      # Package (use the latest production driver)
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Environment variables for NVIDIA
    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    # Kernel modules
    boot.extraModprobeConfig = ''
      options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
    '';

    # Enable suspend for NVIDIA
    systemd.services.nvidia-suspend = {
      description = "NVIDIA suspend";
      before = [ "suspend.target" ];
      wantedBy = [ "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia";
      };
    };

    systemd.services.nvidia-resume = {
      description = "NVIDIA resume";
      after = [ "resume.target" ];
      wantedBy = [ "resume.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe nvidia_modeset nvidia_drm nvidia_uvm nvidia";
      };
    };

    systemd.services.nvidia-hibernate = {
      description = "NVIDIA hibernate";
      before = [ "hibernate.target" ];
      wantedBy = [ "hibernate.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia";
      };
    };

    systemd.services.nvidia-hybrid-sleep = {
      description = "NVIDIA hybrid sleep";
      before = [ "hybrid-sleep.target" ];
      wantedBy = [ "hybrid-sleep.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia";
      };
    };
  };
}
