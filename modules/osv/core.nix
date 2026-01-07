# OSV Core Module - Survival CLI Toolkit
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.core;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      system.stateVersion = cfg.stateVersion;
    }

    {
      nixpkgs.config.allowUnfree = lib.mkDefault cfg.allowUnfree;
    }

    {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    }

    {
      services.dbus.enable = lib.mkDefault true;
      programs.dconf.enable = lib.mkDefault true;
    }

    (lib.mkIf cfg.secretService.enable {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = lib.mkDefault cfg.secretService.seahorse;
    })

    (lib.mkIf cfg.audio.enable {
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = cfg.audio.support32Bit;
        pulse.enable = true;
      };
    })

    (lib.mkIf cfg.printing.enable {
      services.printing.enable = true;
    })

    {
      environment.systemPackages = with pkgs; [
        # Editors (recovery capability)
        vim
        helix

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

        # Crypto basics
        openssl
        gnupg

        # Workstation info
        fastfetch
      ] ++ cfg.extraPackages;
    }
  ]);
}
