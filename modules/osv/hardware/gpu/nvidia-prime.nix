# OSV NVIDIA PRIME Module
#
# Activates when osv.hardware.gpu.stack = "nvidia-prime"
# Provides Intel iGPU + NVIDIA dGPU hybrid configuration.
# Uses PRIME offload mode for selective GPU usage.
#
# ═══════════════════════════════════════════════════════════════════════════════
# WRAITH IS THE REFERENCE PLATFORM FOR THIS MODULE
# ═══════════════════════════════════════════════════════════════════════════════
#
# PRIME MODE: OFFLOAD
# ═══════════════════════════════════════════════════════════════════════════════
#
# This module implements PRIME Offload mode:
#   - Intel iGPU renders by default (power efficient)
#   - NVIDIA dGPU activated on-demand via osv-gpu-run wrapper
#   - Apps run with osv-gpu-run use NVIDIA for rendering
#
# Why Offload Mode:
#   - Best balance of power and performance for laptops
#   - No compositor restart needed to switch GPUs
#   - Predictable behavior across rebuilds
#
# Alternative modes NOT implemented:
#   - PRIME Sync: Always uses NVIDIA (power hungry, hot)
#   - Reverse PRIME: Complex, rarely needed
#
# ═══════════════════════════════════════════════════════════════════════════════
# EXTERNAL DISPLAYS
# ═══════════════════════════════════════════════════════════════════════════════
#
# On many laptops, external displays are wired to the NVIDIA GPU.
# Behavior depends on connection type:
#
#   HDMI/DP via NVIDIA: Works automatically under Wayland
#   USB-C/Thunderbolt: May need compositor-specific config
#
# Known issues:
#   - Some laptops require modesetting for external displays
#   - LSPCON adapters may need display/lspcon.nix workarounds
#
# ═══════════════════════════════════════════════════════════════════════════════
# GPU WRAPPER: osv-gpu-run
# ═══════════════════════════════════════════════════════════════════════════════
#
# The osv-gpu-run wrapper sets PRIME offload environment variables:
#   - __NV_PRIME_RENDER_OFFLOAD=1
#   - __NV_PRIME_RENDER_OFFLOAD_PROVIDER=<provider>
#   - __GLX_VENDOR_LIBRARY_NAME=nvidia
#   - __VK_LAYER_NV_optimus=NVIDIA_only
#
# Usage:
#   osv-gpu-run <application>        # Run app on NVIDIA
#   osv-gpu-run glxinfo              # Verify NVIDIA is active
#
# Gaming:
#   - osv-game wraps games with osv-gpu-run automatically
#   - osv-steam wraps Steam with osv-gpu-run automatically
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  nvCfg = cfg.nvidia;
  primeCfg = cfg.prime;
  isActive = cfg.stack == "nvidia-prime";

  # Driver package defaults to stable if not specified
  # Using stable for reliability; production driver tested on Wraith
  driverPkg = if nvCfg.driverPackage != null
    then nvCfg.driverPackage
    else config.boot.kernelPackages.nvidiaPackages.stable;

  # PRIME-aware GPU wrapper
  # This is the primary interface for GPU offload in OSV
  osvGpuRunPrime = pkgs.writeShellScriptBin cfg.wrapperName ''
    set -euo pipefail

    # PRIME offload environment variables
    # These tell the NVIDIA driver to render this application
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER="${primeCfg.provider}"
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    exec "$@"
  '';

  # Diagnostic tool for verifying PRIME configuration
  osvGpuDiag = pkgs.writeShellScriptBin "osv-gpu-diag" ''
    set -euo pipefail

    echo "═══════════════════════════════════════════════════════════════"
    echo "OSV GPU PRIME DIAGNOSTIC"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "GPU Hardware:"
    ${pkgs.pciutils}/bin/lspci | grep -iE "(vga|3d|display)" || echo "  No GPU detected"
    echo ""
    echo "NVIDIA Driver:"
    if command -v nvidia-smi >/dev/null 2>&1; then
      nvidia-smi --query-gpu=name,driver_version,power.draw --format=csv,noheader 2>/dev/null || echo "  nvidia-smi query failed"
    else
      echo "  nvidia-smi not available"
    fi
    echo ""
    echo "PRIME Configuration:"
    echo "  Intel Bus ID: ${primeCfg.intelBusId}"
    echo "  NVIDIA Bus ID: ${primeCfg.nvidiaBusId}"
    echo "  Provider: ${primeCfg.provider}"
    echo ""
    echo "Default GPU (Intel):"
    ${pkgs.glxinfo}/bin/glxinfo 2>/dev/null | grep "OpenGL renderer" || echo "  glxinfo failed"
    echo ""
    echo "PRIME Offload GPU (NVIDIA):"
    __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia ${pkgs.glxinfo}/bin/glxinfo 2>/dev/null | grep "OpenGL renderer" || echo "  PRIME offload failed"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
  '';
in
{
  # NOTE: PRIME hybrid GPU assertion is enforced in meta/invariants.nix
  config = lib.mkIf isActive (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════
    # Package Policy
    # ═══════════════════════════════════════════════════════════════════
    {
      # NVIDIA requires unfree packages
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    }

    # ═══════════════════════════════════════════════════════════════════
    # NVIDIA Driver Configuration
    # ═══════════════════════════════════════════════════════════════════
    {
      # Register NVIDIA driver
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # Modesetting is required for Wayland
        modesetting.enable = true;

        # Proprietary vs open kernel modules
        # Default: proprietary (more stable on most hardware)
        open = nvCfg.openKernel;

        # nvidia-settings GUI tool
        nvidiaSettings = nvCfg.enableSettings;

        # Driver package
        package = driverPkg;

        # Power management (conservative defaults for stability)
        # Fine-grained PM can cause issues on some hardware
        powerManagement.enable = lib.mkDefault nvCfg.powerManagement;
        powerManagement.finegrained = lib.mkDefault false;

        # PRIME Offload Configuration
        prime = {
          offload = {
            enable = true;
            # Provides nvidia-offload command for debugging
            enableOffloadCmd = true;
          };

          # Bus IDs from host facts.nix
          intelBusId = primeCfg.intelBusId;
          nvidiaBusId = primeCfg.nvidiaBusId;
        };
      };
    }

    # ═══════════════════════════════════════════════════════════════════
    # Kernel Configuration
    # ═══════════════════════════════════════════════════════════════════
    {
      # Required for NVIDIA modesetting under Wayland
      boot.kernelParams = [ "nvidia-drm.modeset=1" ];
    }

    # ═══════════════════════════════════════════════════════════════════
    # GPU Wrapper and Diagnostics
    # ═══════════════════════════════════════════════════════════════════
    {
      environment.systemPackages = [
        osvGpuRunPrime  # Primary GPU offload wrapper
        osvGpuDiag      # Diagnostic tool
        pkgs.glxinfo    # For GPU verification
      ];
    }
  ]);
}
