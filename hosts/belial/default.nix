# Belial Host Configuration
#
# Dell R740XD Server Workstation
# Dual Xeon Gold 6240 (36c/72t), 128GB RAM, RTX 5000
# The big boy.
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
      support32Bit = true;  # Gaming support
    };

    printing.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════
  osv.networking = {
    enable = true;
    hostName = "belial";

    networkManager = {
      enable = true;
      applet = false;  # DMS handles network UX
    };

    ssh = {
      enable = true;
      openFirewall = false;  # Secure by default
    };

    # No Bluetooth on this machine
    bluetooth.enable = false;
  };

  # ═══════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════
  osv.users = {
    primaryUser = "oskodiak";
    primaryUserDescription = "Kodiak";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "libvirtd" ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE - GPU (NVIDIA RTX 5000 dedicated)
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "nvidia";
    enable32Bit = true;

    nvidia = {
      enableSettings = true;
      openKernel = false;  # Proprietary for stability
      powerManagement = false;  # Server/workstation - always on
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
        configHome = "/home/oskodiak";
        configFiles = [
          "/home/oskodiak/.config/DankMaterialShell/settings.json"
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
  # APPS - Full capability workstation
  # ═══════════════════════════════════════════════════════════════════
  osv.apps = {
    userapps.enable = true;

    # Gaming SIP
    gaming = {
      enable = true;
      tier1.steam.remotePlayFirewall = true;
    };

    # Creator SIP
    creator.enable = true;

    # Developer SIP
    developer = {
      enable = true;
      formatter = "alejandra";
      containers = {
        enable = true;
        docker = true;
      };
    };

    # Media SIP
    media.enable = true;

    # Virtualization SIP
    virtualization.enable = true;

    # Security SIP
    security.enable = true;

    # Compute SIP - Dual Xeons demand numerical work
    compute.enable = true;
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
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
