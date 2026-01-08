# Template Host Configuration
#
# Copy this directory as a starting point for new hosts.
# Replace "template" with your hostname.
#
# ═══════════════════════════════════════════════════════════════════════════════
# INSTRUCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
#
# 1. Copy this directory: cp -r hosts/template hosts/YOURHOSTNAME
# 2. Update facts.nix with your hardware facts
# 3. Update this file (default.nix) with your settings
# 4. Add your host to flake.nix (commented out initially)
#
# ═══════════════════════════════════════════════════════════════════════════════
# HARDWARE-CONFIGURATION.NIX - IMPORTANT!
# ═══════════════════════════════════════════════════════════════════════════════
#
# hardware-configuration.nix contains machine-specific settings (disk UUIDs,
# kernel modules, etc.) and MUST be generated on the target hardware:
#
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# This file is NOT portable between machines! Each machine has unique:
#   - Disk/partition UUIDs
#   - Required kernel modules for storage controllers
#   - CPU microcode settings
#
# WORKFLOW:
#   1. Boot target machine (existing NixOS or live ISO)
#   2. Generate: nixos-generate-config --show-hardware-config > hardware-configuration.nix
#   3. Copy hardware-configuration.nix to hosts/YOURHOSTNAME/
#   4. Uncomment the import below
#   5. Uncomment your host in flake.nix
#   6. Build: nixos-rebuild switch --flake .#YOURHOSTNAME
#
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
  };

  # ═══════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════
  osv.networking = {
    enable = true;
    hostName = "template";  # CHANGE THIS
  };

  # ═══════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════
  osv.users = {
    primaryUser = "user";  # CHANGE THIS
    primaryUserDescription = "User";  # CHANGE THIS
  };

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE - GPU
  # ═══════════════════════════════════════════════════════════════════
  osv.hardware.gpu = {
    stack = "intel";  # CHANGE THIS: "intel" | "amd" | "nvidia" | "nvidia-prime"
  };

  # ═══════════════════════════════════════════════════════════════════
  # ENVIRONMENT
  # ═══════════════════════════════════════════════════════════════════
  osv.environment = {
    enable = true;
    session = "niri";

    dms = {
      enable = true;
      greeter.enable = true;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # APPS
  # ═══════════════════════════════════════════════════════════════════
  osv.apps = {
    userapps.enable = true;
    # gaming.enable = false;  # Uncomment to enable
    # creator.enable = false;  # Uncomment to enable
    # developer.enable = false;  # Uncomment to enable
    # media.enable = false;  # Uncomment to enable
  };

  # ═══════════════════════════════════════════════════════════════════
  # BOOTLOADER
  # ═══════════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ═══════════════════════════════════════════════════════════════════
  # LOCALE
  # ═══════════════════════════════════════════════════════════════════
  time.timeZone = "UTC";  # CHANGE THIS
  i18n.defaultLocale = "en_US.UTF-8";
}
