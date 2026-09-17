# TAbelhaNix — Intel GPU configuration
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (config.tabelhanix.gpu == "intel") {
    # Intel GPU
    hardware.graphics = {
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.intel-media-driver
        driversi686Linux.intel-vaapi-driver
      ];
    };

    # Kernel modules
    boot.initrd.kernelModules = [ "i915" ];

    # Environment variables
    environment.variables = {
      LIBVA_DRIVER_NAME = "iHD";
      VDPAU_DRIVER = "va_gl";
    };
  };
}
