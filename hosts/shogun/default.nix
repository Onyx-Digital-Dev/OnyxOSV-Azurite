# Shogun Host Configuration
#
# ThinkPad T580 - Intel integrated graphics laptop
# Scott's workstation
{ config, lib, pkgs, ... }:

{
  imports = [
    # Uncomment after copying hardware-configuration.nix from target:
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

    secretService = {
      enable = true;
      seahorse = true;
    };

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
    hostName = "shogun";

    networkManager = {
      enable = true;
      applet = false;
    };

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
    primaryUser = "osrex";
    primaryUserDescription = "Scott";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE - GPU (Intel integrated)
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "intel";
    enable32Bit = true;
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
        configHome = "/home/osrex";
        configFiles = [
          "/home/osrex/.config/DankMaterialShell/settings.json"
        ];
        logs = {
          save = true;
          path = "/tmp/dms-greeter.log";
        };
      };
    };

    portals.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # APPS
  # ═══════════════════════════════════════════════════════════════════
  osv.apps = {
    userapps.enable = true;
    gaming = {
      enable = true;
      tier1.steam.remotePlayFirewall = true;
    };
    creator.enable = true;
    developer.enable = true;
    media.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # META
  # ═══════════════════════════════════════════════════════════════════
  osv.meta.logging = {
    enable = true;
    level = "info";
  };

  # ═══════════════════════════════════════════════════════════════════
  # BOOTLOADER
  # ═══════════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ═══════════════════════════════════════════════════════════════════
  # LOCALE
  # ═══════════════════════════════════════════════════════════════════
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
