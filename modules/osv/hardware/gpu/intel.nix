# OSV Intel GPU Module
#
# Activates when osv.hardware.gpu.stack = "intel"
# Provides Intel integrated graphics configuration (Mesa).
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  isActive = cfg.stack == "intel";
in
{
  config = lib.mkIf isActive {
    # Intel uses modesetting driver via Mesa
    # On Wayland, this is typically the default behavior
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
  };
}
