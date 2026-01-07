# OSV Security SIP
#
# Trust verification, secrets management, and security inspection tools.
# Does NOT configure kernel hardening, MAC frameworks, or firewall rules.
# Excludes: offensive/pentesting tools, background scanning agents.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.security;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Password management (required)
      bitwarden-desktop
      bitwarden-cli

      # Password store
      pass
      pass-otp

      # Encryption
      gnupg
      age
      minisign
      signify

      # SSH
      ssh-audit

      # Certificates
      openssl
      certbot
      step-cli

      # File integrity
      hashdeep
      rhash
      b3sum

      # YubiKey/hardware tokens (userspace)
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
      pcsclite
      ccid
    ];

    # pcscd required for YubiKey/smart card CCID communication
    services.pcscd.enable = true;
  };
}
