# Athena Host Configuration
#
# Secondary OSV host - Desktop workstation with dedicated NVIDIA GPU.
# This is a THIN config - all behavior comes from OSV modules.
#
# NOTE: This is a placeholder configuration.
# Update hardware-configuration.nix and settings before deploying.
{ config, lib, pkgs, ... }:

{
  imports = [
    # Uncomment after generating hardware-configuration.nix:
    # ./hardware-configuration.nix
    ./facts.nix
  ];

  # ═══════════════════════════════════════════════════════════════════
  # CORE
  # ═══════════════════════════════════════════════════════════════════
  osv.core = {
    enable = true;
    stateVersion = "25.11";
    allowUnfree = true;

    secretService.enable = true;

    audio = {
      enable = true;
      support32Bit = true;
    };

    printing.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════
  osv.networking = {
    enable = true;
    hostName = "athena";

    networkManager.enable = true;

    ssh = {
      enable = true;
      openFirewall = false;
    };

    bluetooth.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════
  osv.users = {
    primaryUser = "user";  # UPDATE THIS
    primaryUserDescription = "User";  # UPDATE THIS
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE - GPU (NVIDIA dedicated)
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "nvidia";  # Dedicated NVIDIA (not PRIME)
    enable32Bit = true;

    nvidia = {
      enableSettings = true;
      openKernel = false;
      powerManagement = false;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # ENVIRONMENT (Niri + DMS)
  # ═══════════════════════════════════════════════════════════════════
  osv.environment = {
    enable = true;
    session = "niri";

    dms = {
      enable = true;
      systemd = true;

      greeter = {
        enable = true;
        # UPDATE configHome to match primary user
        # configHome = "/home/user";
        logs.save = true;
      };
    };

    portals.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # APPS
  # ═══════════════════════════════════════════════════════════════════
  osv.apps = {
    userapps.enable = true;

    # Enable as needed:
    # gaming.enable = true;
    # creator.enable = true;
    # developer.enable = true;
    # media.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # META
  # ═══════════════════════════════════════════════════════════════════
  osv.meta.logging = {
    enable = true;
    level = "info";
  };

  # ═══════════════════════════════════════════════════════════════════
  # BOOTLOADER (host-specific)
  # ═══════════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ═══════════════════════════════════════════════════════════════════
  # LOCALE (host-specific)
  # ═══════════════════════════════════════════════════════════════════
  time.timeZone = "UTC";  # UPDATE THIS
  i18n.defaultLocale = "en_US.UTF-8";
}
