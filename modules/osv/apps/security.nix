# OSV Security SIP
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.security;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Password management
      bitwarden-desktop
      bitwarden-cli

      # Password store
      pass
      pass-otp

      # Encryption (beyond CORE gnupg/openssl)
      age
      minisign
      signify

      # SSH audit
      ssh-audit

      # Certificates
      certbot
      step-cli

      # File integrity
      hashdeep
      rhash
      b3sum

      # YubiKey/hardware tokens
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
      pcsclite
      ccid
    ];

    services.pcscd.enable = true;
  };
}
