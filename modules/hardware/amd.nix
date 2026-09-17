# TAbelhaNix — AMD GPU configuration
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (config.tabelhanix.gpu == "amd") {
    # AMD GPU
    hardware.graphics = {
      extraPackages = with pkgs; [
        # RADV (default Mesa driver) is enabled by default, no extra packages needed
      ];
      extraPackages32 = with pkgs; [
        # 32-bit support for gaming (Mesa32)
      ];
    };

    # Kernel modules
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Kernel parameters
    boot.kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
    ];

    # Environment variables
    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "gpl";
    };
  };
}
