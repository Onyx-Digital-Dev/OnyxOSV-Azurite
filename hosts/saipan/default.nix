# Saipan Host Configuration
#
# New host - hardware TBD.
# All SIPs enabled for full capability.
{ config, lib, pkgs, ... }:

{
  imports = [
    # ./hardware-configuration.nix  # Uncomment after generating
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
    hostName = "saipan";

    networkManager = {
      enable = true;
      applet = false;  # DMS handles network UX
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
  # HARDWARE - GPU
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "intel";  # CHANGE THIS: "intel" | "amd" | "nvidia" | "nvidia-prime"
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
  # APPS - All SIPs enabled
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

    # Compute SIP
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
