# OSV GPU Modules - Entry Point
#
# GPU stack selection is ENUM-based via osv.hardware.gpu.stack.
# Exactly one GPU module activates based on the selected stack.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;

  # GPU wrapper script - always available regardless of stack
  osvGpuRun = pkgs.writeShellScriptBin cfg.wrapperName ''
    set -euo pipefail
    exec "$@"
  '';
in
{
  imports = [
    ./intel.nix
    ./amd.nix
    ./nvidia.nix
    ./nvidia-prime.nix
  ];

  # Base GPU configuration (applies to all stacks)
  config = {
    # Enable graphics stack
    hardware.graphics = {
      enable = true;
      enable32Bit = cfg.enable32Bit;
    };

    # Provide base GPU wrapper (overridden by nvidia-prime if active)
    environment.systemPackages = lib.mkIf (cfg.stack != "nvidia-prime") [
      osvGpuRun
    ];
  };
}
