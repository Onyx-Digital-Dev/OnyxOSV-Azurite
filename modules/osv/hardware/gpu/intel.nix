# OSV Intel GPU Module
#
# Activates when osv.hardware.gpu.stack = "intel"
# Provides Intel integrated graphics configuration (Mesa).
#
# Supports both modern and legacy Intel GPUs:
# - Sandy Bridge (HD 3000) - OpenGL 3.1
# - Ivy Bridge (HD 4000) - OpenGL 4.0
# - Haswell+ - OpenGL 4.5+
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.gpu;
  isActive = cfg.stack == "intel";
in
{
  config = lib.mkIf isActive {
    # Intel uses modesetting driver via Mesa
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

    # Hardware acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = cfg.enable32Bit;
      extraPackages = with pkgs; [
        mesa
        # VAAPI drivers - include both for compatibility
        intel-vaapi-driver    # For older Intel (Sandy Bridge through Haswell)
        intel-media-driver    # For newer Intel (Broadwell+), ignored on old hardware
      ];
      extraPackages32 = lib.mkIf cfg.enable32Bit (with pkgs.driversi686Linux; [
        mesa
        intel-vaapi-driver
      ]);
    };

    # Environment variables for Intel GPU compatibility
    environment.sessionVariables = {
      # Use legacy VAAPI driver for older Intel (Sandy/Ivy Bridge)
      # Newer hardware will override automatically
      LIBVA_DRIVER_NAME = "i965";
    };

    # Mesa utils for diagnostics
    environment.systemPackages = with pkgs; [
      mesa-demos  # provides glxinfo, glxgears
    ];
  };
}
