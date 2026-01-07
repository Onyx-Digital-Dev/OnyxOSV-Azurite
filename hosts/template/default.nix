# Template Host Configuration
#
# Copy this directory as a starting point for new hosts.
# Replace "template" with your hostname.
#
# INSTRUCTIONS:
# 1. Copy this directory: cp -r hosts/template hosts/YOURHOSTNAME
# 2. Update facts.nix with your hardware facts
# 3. Generate hardware-configuration.nix: nixos-generate-config --show-hardware-config
# 4. Update this file with your settings
# 5. Add your host to flake.nix
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
