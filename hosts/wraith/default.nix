# Wraith Host Configuration
#
# Primary OSV testbed - NVIDIA PRIME hybrid laptop.
# This is a THIN config - all behavior comes from OSV modules.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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

    # Audio via PipeWire (modularized)
    audio = {
      enable = true;
      support32Bit = true;
    };

    # Printing via CUPS (modularized)
    printing.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════
  osv.networking = {
    enable = true;
    hostName = "wraith";

    networkManager = {
      enable = true;
      applet = false;  # DMS handles network UX
      wifiPowersave = false;  # Stability over power
    };

    ssh = {
      enable = true;
      openFirewall = false;  # Secure by default
    };

    bluetooth = {
      enable = true;
      blueman = false;  # DMS handles Bluetooth UX
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════
  osv.users = {
    primaryUser = "oskodiak";
    primaryUserDescription = "Kodiak";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE - GPU (NVIDIA PRIME)
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "nvidia-prime";
    enable32Bit = true;

    nvidia = {
      enableSettings = true;
      openKernel = false;  # Proprietary for stability
      powerManagement = false;  # Conservative
    };

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      provider = "NVIDIA-G0";
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
  # APPS
  # ═══════════════════════════════════════════════════════════════════
  osv.apps = {
    userapps = {
      enable = true;
      browser = "firefox";
    };

    # Gaming SIP - All tiers enabled by default
    # Explicit structure shown for documentation; all defaults are true
    gaming = {
      enable = true;

      # Tier 1: MUST SHIP - Launchers and streaming
      tier1 = {
        steam.enable = true;
        steam.remotePlayFirewall = true;
        heroic = true;
        lutris = true;
        obs = true;
        discord = true;
      };

      # Tier 2: DEFAULT ON - Performance tools
      tier2 = {
        gamemode = true;
        mangohud = true;
        gamescope = true;
        protonup = true;
      };

      # Tier 3: OPTIONAL - Advanced tuning
      tier3 = {
        vkbasalt = true;
        goverlay = true;
        winetricks = true;
      };
    };

    creator = {
      enable = true;
      graphics = true;
      video = false;
      audio = false;
    };
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
