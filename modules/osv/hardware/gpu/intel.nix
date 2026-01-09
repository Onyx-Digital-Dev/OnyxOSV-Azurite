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
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

    # Hardware acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = cfg.enable32Bit;
      extraPackages = with pkgs; [
        intel-media-driver    # VAAPI for newer Intel (Broadwell+)
        intel-vaapi-driver    # VAAPI for older Intel
        vpl-gpu-rt            # QSV
        vulkan-loader
        intel-compute-runtime # OpenCL
      ];
      extraPackages32 = lib.mkIf cfg.enable32Bit (with pkgs.driversi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        vulkan-loader
      ]);
    };

    # Vulkan ICD
    environment.systemPackages = [ pkgs.vulkan-tools ];
  };
}
