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

    gaming = {
      enable = true;
      enableGameMode = true;
      enableMangoHud = true;

      steam = {
        enable = true;
        remotePlayFirewall = true;
      };

      heroic = true;

      tools = {
        gamescope = true;
        protonup = true;
      };

      comms = {
        discord = true;
        obs = true;
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

  # ═══════════════════════════════════════════════════════════════════
  # AUDIO (PipeWire baseline)
  # ═══════════════════════════════════════════════════════════════════
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # PRINTING
  # ═══════════════════════════════════════════════════════════════════
  services.printing.enable = true;
}
