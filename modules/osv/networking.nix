# OSV Networking Module
#
# Provides network stack configuration:
# - NetworkManager
# - Firewall
# - DNS (systemd-resolved)
# - SSH
# - Tailscale
# - Bluetooth
# - VPN (WireGuard, OpenVPN)
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.networking;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Hostname
    (lib.mkIf (cfg.hostName != null) {
      networking.hostName = cfg.hostName;
    })

    # Firewall
    {
      networking.firewall = {
        enable = cfg.firewall.enable;
        allowPing = cfg.firewall.allowPing;
        allowedTCPPorts = cfg.firewall.allowedTCPPorts;
        allowedUDPPorts = cfg.firewall.allowedUDPPorts;
      };
    }

    # NetworkManager
    (lib.mkIf cfg.networkManager.enable {
      networking.networkmanager = {
        enable = true;
        wifi.powersave = cfg.networkManager.wifiPowersave;
        dns = if cfg.networkManager.dns == "none" then "none" else "systemd-resolved";
        plugins = lib.optionals cfg.openvpn.enable [ pkgs.networkmanager-openvpn ];
      };
    })

    # NetworkManager applet
    (lib.mkIf (cfg.networkManager.enable && cfg.networkManager.applet) {
      environment.systemPackages = [ pkgs.networkmanagerapplet ];
    })

    # DNS (systemd-resolved)
    (lib.mkIf cfg.dns.enableResolved {
      services.resolved = {
        enable = true;
        dnssec = cfg.dns.dnssec;
        fallbackDns = cfg.dns.fallbackServers;
      };
    })

    # SSH
    (lib.mkIf cfg.ssh.enable {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = cfg.ssh.passwordAuth;
          PermitRootLogin = cfg.ssh.permitRootLogin;
        };
      };
    })

    # SSH firewall
    (lib.mkIf cfg.ssh.openFirewall {
      networking.firewall.allowedTCPPorts = lib.mkAfter [ 22 ];
    })

    # Tailscale
    (lib.mkIf cfg.tailscale.enable {
      services.tailscale = {
        enable = true;
        openFirewall = cfg.tailscale.openFirewall;
        useRoutingFeatures = cfg.tailscale.useRoutingFeatures;
      };
    })

    # Bluetooth
    (lib.mkIf cfg.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = cfg.bluetooth.blueman;
    })

    # VPN tools and networking packages
    {
      environment.systemPackages = with pkgs;
        # WireGuard tools
        lib.optionals cfg.wireguard.enableTools [ wireguard-tools ]
        # OpenVPN with NetworkManager integration
        ++ lib.optionals cfg.openvpn.enable [ openvpn networkmanager-openvpn ]
        # Bluetooth tools
        ++ lib.optionals cfg.bluetooth.enable [ bluez bluez-tools ];
    }
  ]);
}
