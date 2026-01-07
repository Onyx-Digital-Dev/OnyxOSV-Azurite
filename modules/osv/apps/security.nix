# OSV Security SIP (Software Intent Profile)
#
# PURPOSE:
# "This workstation has tools for trust verification, secrets management,
# and security inspection without silently hardening the system or altering
# its security posture."
#
# CAPABILITIES:
#   - Encrypt and sign files and communications (GPG, age)
#   - Manage passwords and secrets (pass, Bitwarden)
#   - Inspect and manage SSH keys and certificates
#   - Verify file integrity and checksums
#   - Inspect X.509 certificates and TLS connections
#   - Manage YubiKey and hardware token interactions (userspace tools only)
#   - Audit and inspect system trust stores
#
# BOUNDARY: This module provides security TOOLS ONLY.
# It does NOT configure:
#   - Kernel hardening (sysctl, lockdown policy)
#   - MAC frameworks (SELinux, AppArmor, TOMOYO)
#   - Firewall rules (iptables, nftables)
#   - Antivirus or EDR agents
#   - VPN (belongs to osv.networking.vpn)
#
# EXPLICIT EXCLUSIONS:
#   - Offensive security / pentesting tools
#   - Exploitation frameworks, fuzzers, attack tools
#   - Silent policy changes
#   - Background scanning agents
#
# KEYRING INTEGRATION:
#   OSV environment uses GNOME Keyring. This SIP integrates with that
#   approach and does NOT introduce alternative keyring frameworks.
#
# COMPOSABILITY:
#   This SIP is designed to work alongside all other SIPs without conflicts.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.security;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # ─────────────────────────────────────────────────────────────────────
      # Password & Secrets Management (REQUIRED)
      # ─────────────────────────────────────────────────────────────────────
      bitwarden-desktop   # Cross-platform password manager (GUI)
      bitwarden-cli       # Bitwarden command-line interface

      # ─────────────────────────────────────────────────────────────────────
      # Password Store Ecosystem
      # ─────────────────────────────────────────────────────────────────────
      pass                # Standard Unix password manager (GPG-based)
      pass-otp            # OTP support for pass

      # ─────────────────────────────────────────────────────────────────────
      # Encryption & Signing
      # ─────────────────────────────────────────────────────────────────────
      gnupg               # GNU Privacy Guard - encryption and signing
      age                 # Modern encryption tool (simpler than GPG)
      minisign            # Dead simple signing tool
      signify             # OpenBSD signing tool

      # ─────────────────────────────────────────────────────────────────────
      # SSH Key Management
      # ─────────────────────────────────────────────────────────────────────
      ssh-audit           # SSH server & client auditing
      sshpass             # Non-interactive SSH password provider

      # ─────────────────────────────────────────────────────────────────────
      # Certificate & TLS Inspection
      # ─────────────────────────────────────────────────────────────────────
      openssl             # TLS/SSL toolkit and certificate utilities
      certbot             # Certificate management (Let's Encrypt)
      step-cli            # Toolkit for working with certificates

      # ─────────────────────────────────────────────────────────────────────
      # File Integrity & Verification
      # ─────────────────────────────────────────────────────────────────────
      hashdeep            # Compute and audit hashsets
      rhash               # Hash utility supporting many algorithms
      b3sum               # BLAKE3 cryptographic hash

      # ─────────────────────────────────────────────────────────────────────
      # YubiKey & Hardware Token Support (Userspace Only)
      # ─────────────────────────────────────────────────────────────────────
      yubikey-manager     # YubiKey configuration tool
      yubikey-personalization # YubiKey personalization tool
      yubico-piv-tool     # PIV tool for YubiKey
      pcsclite            # PC/SC smart card middleware
      ccid                # PC/SC driver for USB CCID smart cards

      # ─────────────────────────────────────────────────────────────────────
      # Trust Store Inspection
      # ─────────────────────────────────────────────────────────────────────
      # ca-certificates is typically in base system
      # openssl above provides trust store inspection capabilities
    ];

    # Enable PC/SC daemon for smart card / YubiKey support
    services.pcscd.enable = true;
  };
}
