# OSV Core Module
#
# Provides essential system baseline:
# - Unfree package policy
# - Core system services (dbus, dconf)
# - Secret service provider
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
