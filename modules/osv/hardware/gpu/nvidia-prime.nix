# OSV NVIDIA PRIME Module
#
# Activates when osv.hardware.gpu.stack = "nvidia-prime"
# Provides Intel iGPU + NVIDIA dGPU hybrid configuration.
# Uses PRIME offload mode for selective GPU usage.
#
# WRAITH IS THE REFERENCE PLATFORM FOR THIS MODULE.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  nvCfg = cfg.nvidia;
  primeCfg = cfg.prime;
  isActive = cfg.stack == "nvidia-prime";

  # Driver package defaults to stable if not specified
  driverPkg = if nvCfg.driverPackage != null
    then nvCfg.driverPackage
    else config.boot.kernelPackages.nvidiaPackages.stable;

  # PRIME-aware GPU wrapper
  osvGpuRunPrime = pkgs.writeShellScriptBin cfg.wrapperName ''
    set -euo pipefail

    # PRIME offload environment variables
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER="${primeCfg.provider}"
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    exec "$@"
  '';
in
{
  config = lib.mkIf isActive (lib.mkMerge [
    # Assertion: PRIME requires hybrid GPU facts
    {
      assertions = [{
        assertion = config.osv.facts.gpu == "hybrid";
        message = "OSV: nvidia-prime stack requires osv.facts.gpu = \"hybrid\"";
      }];
    }

    # NVIDIA requires unfree
    {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    }

    # NVIDIA driver with PRIME offload
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = nvCfg.openKernel;
        nvidiaSettings = nvCfg.enableSettings;
        package = driverPkg;

        # Conservative power management
        powerManagement.enable = lib.mkDefault nvCfg.powerManagement;
        powerManagement.finegrained = lib.mkDefault false;

        # PRIME offload configuration
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };

          intelBusId = primeCfg.intelBusId;
          nvidiaBusId = primeCfg.nvidiaBusId;
        };
      };
    }

    # Kernel parameter for modesetting
    {
      boot.kernelParams = [ "nvidia-drm.modeset=1" ];
    }

    # PRIME-aware GPU wrapper (overrides base wrapper)
    {
      environment.systemPackages = [ osvGpuRunPrime ];
    }
  ]);
}
