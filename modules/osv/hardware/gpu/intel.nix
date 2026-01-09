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
        mesa
        intel-media-driver    # VAAPI for newer Intel (Broadwell+)
        intel-vaapi-driver    # VAAPI for older Intel
        vpl-gpu-rt            # QSV
        intel-compute-runtime # OpenCL
      ];
      extraPackages32 = lib.mkIf cfg.enable32Bit (with pkgs.driversi686Linux; [
        mesa
        intel-media-driver
        intel-vaapi-driver
      ]);
    };

    # Environment variables for Intel GPU compatibility
    environment.sessionVariables = {
      # Force Mesa for Vulkan (Intel ANV driver)
      AMD_VULKAN_ICD = "RADV";  # Prevent AMD fallback
      # Help Steam CEF rendering
      STEAM_FORCE_DESKTOPUI_SCALING = "1";
    };

    # Vulkan tools and mesa utils for diagnostics
    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos  # provides glxinfo, glxgears
    ];
  };
}
