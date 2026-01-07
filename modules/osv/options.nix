# OSV Options - SINGLE SOURCE OF OPTION DEFINITIONS
#
# ALL osv.* options are defined here and ONLY here.
# Modules consume these options; they do not define them.
#
# This ensures:
# - Clear option discoverability
# - No option conflicts
# - Single source of truth for the option schema
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.osv = {
    # ═══════════════════════════════════════════════════════════════════
    # CORE OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    core = {
      enable = mkEnableOption "OSV core baseline (essential tools + policies)";

      stateVersion = mkOption {
        type = types.str;
        default = "25.11";
        description = "NixOS state version for this host";
      };

      allowUnfree = mkOption {
        type = types.bool;
        default = true;
        description = "Allow unfree packages system-wide";
      };

      secretService = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable a Secret Service provider (GNOME Keyring)";
        };

        seahorse = mkOption {
          type = types.bool;
          default = false;
          description = "Install Seahorse (GUI for keyrings)";
        };
      };

      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional core packages for this host";
      };

      # Audio subsystem
      audio = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable PipeWire audio stack";
        };

        support32Bit = mkOption {
          type = types.bool;
          default = true;
          description = "Enable 32-bit audio support (for games)";
        };
      };

      # Printing subsystem
      printing = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable CUPS printing";
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # NETWORKING OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    networking = {
      enable = mkEnableOption "OSV networking baseline";

      hostName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "System hostname";
      };

      networkManager = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable NetworkManager";
        };

        applet = mkOption {
          type = types.bool;
          default = false;
          description = "Install nm-applet (tray applet)";
        };

        wifiPowersave = mkOption {
          type = types.nullOr types.bool;
          default = false;
          description = "Wi-Fi powersave policy (false = disabled for stability)";
        };

        dns = mkOption {
          type = types.enum [ "systemd-resolved" "none" ];
          default = "systemd-resolved";
          description = "DNS integration strategy";
        };
      };

      dns = {
        enableResolved = mkOption {
          type = types.bool;
          default = true;
          description = "Enable systemd-resolved";
        };

        fallbackServers = mkOption {
          type = types.listOf types.str;
          default = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
          description = "Fallback DNS servers";
        };

        dnssec = mkOption {
          type = types.enum [ "no" "allow-downgrade" "yes" ];
          default = "allow-downgrade";
          description = "DNSSEC mode";
        };
      };

      firewall = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable NixOS firewall";
        };

        allowPing = mkOption {
          type = types.bool;
          default = false;
          description = "Allow ICMP echo requests";
        };

        allowedTCPPorts = mkOption {
          type = types.listOf types.port;
          default = [];
          description = "Additional allowed TCP ports";
        };

        allowedUDPPorts = mkOption {
          type = types.listOf types.port;
          default = [];
          description = "Additional allowed UDP ports";
        };
      };

      ssh = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable OpenSSH daemon";
        };

        passwordAuth = mkOption {
          type = types.bool;
          default = false;
          description = "Allow SSH password authentication";
        };

        permitRootLogin = mkOption {
          type = types.enum [ "no" "prohibit-password" "yes" ];
          default = "no";
          description = "Root login policy for SSH";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open firewall for SSH (port 22)";
        };
      };

      tailscale = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Tailscale";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = true;
          description = "Let Tailscale manage firewall rules";
        };

        useRoutingFeatures = mkOption {
          type = types.enum [ "none" "client" "server" "both" ];
          default = "none";
          description = "Tailscale routing features";
        };
      };

      bluetooth = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Bluetooth stack";
        };

        blueman = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Blueman (tray applet)";
        };
      };

      # VPN options
      wireguard = {
        enableTools = mkOption {
          type = types.bool;
          default = true;
          description = "Install WireGuard tools";
        };
      };

      openvpn = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Install OpenVPN and NetworkManager plugin";
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # USER OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    users = {
      primaryUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Primary user account name";
      };

      primaryUserDescription = mkOption {
        type = types.str;
        default = "OSV User";
        description = "Primary user display name";
      };

      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ "networkmanager" "wheel" ];
        description = "Additional groups for primary user";
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # HARDWARE OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    hardware = {
      gpu = {
        # ENUM-BASED GPU SELECTION (mutually exclusive)
        stack = mkOption {
          type = types.enum [ "intel" "amd" "nvidia" "nvidia-prime" ];
          default = "intel";
          description = ''
            GPU stack to use. This is mutually exclusive:
            - intel: Intel integrated graphics (Mesa)
            - amd: AMD graphics (Mesa/AMDGPU)
            - nvidia: NVIDIA discrete only (proprietary driver)
            - nvidia-prime: Intel iGPU + NVIDIA dGPU hybrid (PRIME offload)
          '';
        };

        enable32Bit = mkOption {
          type = types.bool;
          default = true;
          description = "Enable 32-bit graphics support (required for many games)";
        };

        wrapperName = mkOption {
          type = types.str;
          default = "osv-gpu-run";
          description = "Name of the GPU wrapper command";
        };

        # NVIDIA-specific options (only used when stack is nvidia or nvidia-prime)
        nvidia = {
          driverPackage = mkOption {
            type = types.nullOr types.package;
            default = null;
            description = "NVIDIA driver package (defaults to stable)";
          };

          enableSettings = mkOption {
            type = types.bool;
            default = true;
            description = "Install nvidia-settings";
          };

          openKernel = mkOption {
            type = types.bool;
            default = false;
            description = "Use open-source NVIDIA kernel modules";
          };

          powerManagement = mkOption {
            type = types.bool;
            default = false;
            description = "Enable NVIDIA power management";
          };
        };

        # PRIME-specific options (only used when stack is nvidia-prime)
        prime = {
          intelBusId = mkOption {
            type = types.str;
            default = "PCI:0:2:0";
            description = "PCI bus ID for Intel iGPU";
          };

          nvidiaBusId = mkOption {
            type = types.str;
            default = "PCI:1:0:0";
            description = "PCI bus ID for NVIDIA dGPU";
          };

          provider = mkOption {
            type = types.str;
            default = "NVIDIA-G0";
            description = "GL/Vulkan provider name for PRIME offload";
          };
        };
      };

      display = {
        # LSPCON workaround for specific display adapters
        lspcon = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable LSPCON display adapter workaround";
          };
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # ENVIRONMENT OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    environment = {
      enable = mkEnableOption "OSV desktop environment stack";

      session = mkOption {
        type = types.enum [ "niri" ];
        default = "niri";
        description = "Wayland compositor/session to use";
      };

      dms = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable DankMaterialShell";
        };

        systemd = mkOption {
          type = types.bool;
          default = true;
          description = "Enable DMS systemd integration";
        };

        greeter = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable DankGreeter";
          };

          configHome = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "User home for greeter config sync";
          };

          configFiles = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Config files to sync to greeter";
          };

          logs = {
            save = mkOption {
              type = types.bool;
              default = true;
              description = "Save greeter logs";
            };

            path = mkOption {
              type = types.str;
              default = "/tmp/dms-greeter.log";
              description = "Greeter log path";
            };
          };
        };
      };

      portals = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable xdg-desktop-portal";
        };

        extraPortals = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Additional portal implementations";
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # APP STACK OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    apps = {
      # User apps (always enabled by default)
      userapps = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable base user applications";
        };

        browser = mkOption {
          type = types.enum [ "firefox" "chromium" "none" ];
          default = "firefox";
          description = "Default web browser";
        };
      };

      # ═══════════════════════════════════════════════════════════════════
      # Gaming SIP (Software Intent Profile)
      # ═══════════════════════════════════════════════════════════════════
      #
      # BOUNDARY: This SIP provides gaming SOFTWARE ONLY.
      # GPU configuration is handled by osv.hardware.gpu.*
      # Environment configuration is handled by osv.environment.*
      #
      # TIER STRUCTURE:
      #   Tier 1 (MUST SHIP): Steam, Heroic, Lutris, OBS Studio, Discord
      #   Tier 2 (default on): ProtonUp-Qt, MangoHud, Gamescope, GameMode
      #   Tier 3 (optional):   vkBasalt, Goverlay
      #
      # ═══════════════════════════════════════════════════════════════════
      gaming = {
        enable = mkEnableOption "OSV gaming SIP";

        # Integration point for GPU wrapper (NOT GPU configuration)
        # This receives the wrapper name from osv.hardware.gpu.wrapperName
        gpuWrapper = mkOption {
          type = types.str;
          default = "osv-gpu-run";
          description = "GPU wrapper command for games (integration point)";
        };

        # ═════════════════════════════════════════════════════════════════
        # TIER 1: MUST SHIP - Core gaming launchers and streaming
        # ═════════════════════════════════════════════════════════════════
        tier1 = {
          steam = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable Steam";
            };

            remotePlayFirewall = mkOption {
              type = types.bool;
              default = true;
              description = "Open firewall for Steam Remote Play";
            };
          };

          heroic = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Heroic (Epic/GOG launcher)";
          };

          lutris = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Lutris (universal game launcher)";
          };

          obs = mkOption {
            type = types.bool;
            default = true;
            description = "Enable OBS Studio for streaming/recording";
          };

          discord = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Discord for gaming communications";
          };
        };

        # ═════════════════════════════════════════════════════════════════
        # TIER 2: DEFAULT ON - Essential gaming tools
        # ═════════════════════════════════════════════════════════════════
        tier2 = {
          protonup = mkOption {
            type = types.bool;
            default = true;
            description = "Enable ProtonUp-Qt for Proton version management";
          };

          mangohud = mkOption {
            type = types.bool;
            default = true;
            description = "Enable MangoHud performance overlay";
          };

          gamescope = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Gamescope compositor";
          };

          gamemode = mkOption {
            type = types.bool;
            default = true;
            description = "Enable GameMode performance optimizer";
          };
        };

        # ═════════════════════════════════════════════════════════════════
        # TIER 3: OPTIONAL - Advanced tuning tools
        # ═════════════════════════════════════════════════════════════════
        tier3 = {
          vkbasalt = mkOption {
            type = types.bool;
            default = true;
            description = "Enable vkBasalt Vulkan post-processing layer";
          };

          goverlay = mkOption {
            type = types.bool;
            default = true;
            description = "Enable GOverlay (MangoHud/vkBasalt configurator)";
          };

          winetricks = mkOption {
            type = types.bool;
            default = true;
            description = "Enable winetricks for Wine configuration";
          };
        };
      };

      # Creator stack
      creator = {
        enable = mkEnableOption "OSV creator stack";

        graphics = mkOption {
          type = types.bool;
          default = true;
          description = "Install graphics tools (Krita, GIMP, Inkscape, Blender)";
        };

        video = mkOption {
          type = types.bool;
          default = false;
          description = "Install video tools (Kdenlive, Shotcut)";
        };

        audio = mkOption {
          type = types.bool;
          default = false;
          description = "Install audio tools (Ardour, Audacity)";
        };
      };

      # Developer stack
      developer = {
        enable = mkEnableOption "OSV developer stack";

        editors = {
          vscode = mkOption {
            type = types.bool;
            default = false;
            description = "Install VS Code";
          };

          neovim = mkOption {
            type = types.bool;
            default = true;
            description = "Install Neovim";
          };
        };

        languages = {
          rust = mkOption {
            type = types.bool;
            default = false;
            description = "Install Rust toolchain";
          };

          go = mkOption {
            type = types.bool;
            default = false;
            description = "Install Go toolchain";
          };

          python = mkOption {
            type = types.bool;
            default = true;
            description = "Install Python";
          };

          node = mkOption {
            type = types.bool;
            default = true;
            description = "Install Node.js";
          };
        };
      };

      # Media stack
      media = {
        enable = mkEnableOption "OSV media stack";

        video = mkOption {
          type = types.bool;
          default = true;
          description = "Install video players (mpv, vlc)";
        };

        audio = mkOption {
          type = types.bool;
          default = true;
          description = "Install audio players";
        };

        images = mkOption {
          type = types.bool;
          default = true;
          description = "Install image viewers";
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # HOST FACTS (set per-host, read-only at evaluation)
    # ═══════════════════════════════════════════════════════════════════
    facts = {
      gpu = mkOption {
        type = types.enum [ "intel" "amd" "nvidia" "hybrid" ];
        default = "intel";
        description = ''
          Hardware GPU configuration:
          - intel: Intel iGPU only
          - amd: AMD GPU only
          - nvidia: NVIDIA dGPU only
          - hybrid: Intel iGPU + NVIDIA dGPU
        '';
      };

      hasInternalDisplay = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this machine has a built-in display (laptop)";
      };

      isLaptop = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this is a laptop/portable device";
      };

      hasBluetooth = mkOption {
        type = types.bool;
        default = true;
        description = "Whether this machine has Bluetooth hardware";
      };

      primaryNetwork = mkOption {
        type = types.enum [ "ethernet" "wifi" "both" ];
        default = "ethernet";
        description = "Primary network interface type";
      };
    };

    # ═══════════════════════════════════════════════════════════════════
    # META OPTIONS
    # ═══════════════════════════════════════════════════════════════════
    meta = {
      logging = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable OSV diagnostic logging";
        };

        level = mkOption {
          type = types.enum [ "error" "warn" "info" "debug" ];
          default = "info";
          description = "Logging verbosity level";
        };
      };
    };
  };

  # No config block - this module only defines options
  config = {};
}
