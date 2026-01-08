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
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "libvirtd" ];
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
    userapps.enable = true;

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

    # Creator SIP - Full content creation stack
    # Over-capability is intentional; all categories default true
    creator = {
      enable = true;

      # Graphics & Digital Art
      graphics = {
        enable = true;
        gimp = true;
        inkscape = true;
        krita = true;
      };

      # 3D Modeling
      modeling = {
        enable = true;
        blender = true;
      };

      # Photography
      photo = {
        enable = true;
        darktable = true;
      };

      # Video Editing
      video = {
        enable = true;
        kdenlive = true;
      };

      # Audio Production
      audio = {
        enable = true;
        audacity = true;
        ardour = true;
      };

      # Pipeline Tools
      pipeline = {
        enable = true;
        ffmpeg = true;
        imagemagick = true;
        exiftool = true;
      };

      # Pixel Art (for Cricket and Bean)
      pixelart = {
        enable = true;
        libresprite = true;
        mtpaint = true;
      };
    };

    # Developer SIP - Professional development capability
    # "A warrior in a garden, not a gardener in a war."
    developer = {
      enable = true;

      # Nix formatter - conservative default
      formatter = "alejandra";

      # Containers
      containers = {
        enable = true;
        docker = true;
      };

      editors = {
        enable = true;
        vscodium = true;
        neovim = true;
      };

      # Languages (baseline capability; devShells are primary workflow)
      languages = {
        enable = true;
        rust = true;
        python = true;
      };

      # Core development tooling
      coreTools.enable = true;
    };

    # Media SIP - High-quality media consumption
    media = {
      enable = true;

      # Video playback
      video = {
        enable = true;
        mpv = true;
        vlc = true;
      };

      # Music playback
      music = {
        enable = true;
        strawberry = true;
      };

      # Media clients (streaming from servers)
      clients = {
        enable = true;
        jellyfin = true;
      };

      # Utilities
      utilities = {
        enable = true;
        ytdlp = true;
        mediainfo = true;
        ffmpeg = true;
      };
    };

    # Virtualization SIP - Local VM management
    virtualization.enable = true;

    # Security SIP - Trust verification and secrets management
    security.enable = true;

    # Compute SIP - Data science and numerical computing
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

  # P15 ThinkPad workarounds
  boot.blacklistedKernelModules = [ "ucsi_ccg" ];
  boot.kernelParams = [ "video=HDMI-A-3:d" "drm.debug=0" ];
  boot.consoleLogLevel = 3;

  # ═══════════════════════════════════════════════════════════════════
  # LOCALE (host-specific)
  # ═══════════════════════════════════════════════════════════════════
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
