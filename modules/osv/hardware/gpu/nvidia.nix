# OSV NVIDIA GPU Module
#
# Activates when osv.hardware.gpu.stack = "nvidia"
# Provides NVIDIA discrete-only configuration (proprietary driver).
# NOT for hybrid laptops - use nvidia-prime for those.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  nvCfg = cfg.nvidia;
  isActive = cfg.stack == "nvidia";

  # Driver package defaults to stable if not specified
  driverPkg = if nvCfg.driverPackage != null
    then nvCfg.driverPackage
    else config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  config = lib.mkIf isActive {
    # NVIDIA requires unfree
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    # NVIDIA driver
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = nvCfg.openKernel;
      nvidiaSettings = nvCfg.enableSettings;
      package = driverPkg;

      # Conservative power management defaults
      powerManagement.enable = lib.mkDefault nvCfg.powerManagement;
      powerManagement.finegrained = lib.mkDefault false;
    };

    # Kernel parameter for modesetting
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
