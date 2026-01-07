# OSV Core Module
#
# Provides essential system baseline:
# - Unfree package policy
# - Core system services (dbus, dconf)
# - Secret service provider
# - Audio stack (PipeWire)
# - Printing (CUPS)
# - Essential tooling
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.core;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # State version
    {
      system.stateVersion = cfg.stateVersion;
    }

    # Unfree package policy
    {
      nixpkgs.config.allowUnfree = lib.mkDefault cfg.allowUnfree;
    }

    # Nix settings
    {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    }

    # Core system services
    {
      services.dbus.enable = lib.mkDefault true;
      programs.dconf.enable = lib.mkDefault true;
    }

    # Secret Service provider (GNOME Keyring)
    (lib.mkIf cfg.secretService.enable {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = lib.mkDefault cfg.secretService.seahorse;
    })

    # Audio stack (PipeWire)
    (lib.mkIf cfg.audio.enable {
      # Disable PulseAudio (replaced by PipeWire)
      services.pulseaudio.enable = false;

      # Real-time scheduling for audio
      security.rtkit.enable = true;

      # PipeWire configuration
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = cfg.audio.support32Bit;
        pulse.enable = true;
      };
    })

    # Printing (CUPS)
    (lib.mkIf cfg.printing.enable {
      services.printing.enable = true;
    })

    # Essential packages
    {
      environment.systemPackages = with pkgs; [
        # Editors
        vim
        helix

        # Terminal
        kitty

        # VCS
        git

        # Fetch
        curl
        wget

        # Search & navigate
        ripgrep
        fd
        lsd
        jq
        file
        tree

        # Archives
        unzip
        zip
        p7zip

        # System monitoring
        htop
        btop
        ncdu
        lsof
        strace

        # Hardware info
        pciutils
        usbutils
        dmidecode

        # Network diagnostics
        iproute2
        iputils
        dnsutils
        traceroute
        mtr
        nmap

        # Session helpers
        tmux
        rsync

        # Crypto
        openssl
        gnupg
      ] ++ cfg.extraPackages;
    }
  ]);
}
