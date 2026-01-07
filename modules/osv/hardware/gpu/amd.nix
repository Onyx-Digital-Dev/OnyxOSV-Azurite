# OSV AMD GPU Module
#
# Activates when osv.hardware.gpu.stack = "amd"
# Provides AMD graphics configuration (Mesa/AMDGPU).
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  isActive = cfg.stack == "amd";
in
{
  config = lib.mkIf isActive {
    # AMD uses modesetting driver via Mesa/AMDGPU
    # Modern AMD GPUs work automatically on NixOS
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
  };
}
