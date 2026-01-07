# OSV Invariants Module
#
# Enforces OSV invariants at evaluation time.
# Invalid configurations MUST fail here, not at boot.
#
# INVARIANT CATEGORIES:
# 1. Hardware consistency (GPU stack vs facts)
# 2. Module dependencies (DMS → environment → core)
# 3. User configuration sanity
# 4. App stack requirements
{ config, lib, pkgs, ... }:

let
  cfg = config.osv;
  facts = cfg.facts;
  gpuStack = cfg.hardware.gpu.stack;
in
{
  config = {
    assertions = [
      # ═══════════════════════════════════════════════════════════════════
      # HARDWARE INVARIANTS
      # ═══════════════════════════════════════════════════════════════════

      # PRIME requires hybrid GPU hardware
      {
        assertion = gpuStack != "nvidia-prime" || facts.gpu == "hybrid";
        message = ''
          OSV INVARIANT VIOLATION: GPU stack mismatch
          osv.hardware.gpu.stack = "nvidia-prime" requires osv.facts.gpu = "hybrid"
          Current facts.gpu = "${facts.gpu}"

          PRIME offload requires both Intel iGPU and NVIDIA dGPU.
          If this machine only has NVIDIA, use osv.hardware.gpu.stack = "nvidia"
        '';
      }

      # nvidia-only stack requires nvidia or hybrid hardware
      {
        assertion = gpuStack != "nvidia" || (facts.gpu == "nvidia" || facts.gpu == "hybrid");
        message = ''
          OSV INVARIANT VIOLATION: GPU stack mismatch
          osv.hardware.gpu.stack = "nvidia" requires osv.facts.gpu = "nvidia" or "hybrid"
          Current facts.gpu = "${facts.gpu}"

          Set osv.facts.gpu to match your hardware configuration.
        '';
      }

      # AMD stack requires AMD hardware
      {
        assertion = gpuStack != "amd" || facts.gpu == "amd";
        message = ''
          OSV INVARIANT VIOLATION: GPU stack mismatch
          osv.hardware.gpu.stack = "amd" requires osv.facts.gpu = "amd"
          Current facts.gpu = "${facts.gpu}"
        '';
      }

      # Intel stack requires Intel (or hybrid where we use Intel)
      {
        assertion = gpuStack != "intel" || (facts.gpu == "intel" || facts.gpu == "hybrid");
        message = ''
          OSV INVARIANT VIOLATION: GPU stack mismatch
          osv.hardware.gpu.stack = "intel" requires osv.facts.gpu = "intel" or "hybrid"
          Current facts.gpu = "${facts.gpu}"
        '';
      }

      # ═══════════════════════════════════════════════════════════════════
      # MODULE DEPENDENCY INVARIANTS
      # ═══════════════════════════════════════════════════════════════════

      # Environment requires session to be selected
      {
        assertion = !cfg.environment.enable || cfg.environment.session != null;
        message = ''
          OSV INVARIANT VIOLATION: Missing session
          osv.environment.enable = true requires osv.environment.session to be set
        '';
      }

      # DMS requires environment to be enabled
      {
        assertion = !cfg.environment.dms.enable || cfg.environment.enable;
        message = ''
          OSV INVARIANT VIOLATION: Dependency chain broken
          osv.environment.dms.enable = true requires osv.environment.enable = true
        '';
      }

      # Greeter requires DMS
      {
        assertion = !cfg.environment.dms.greeter.enable || cfg.environment.dms.enable;
        message = ''
          OSV INVARIANT VIOLATION: Dependency chain broken
          osv.environment.dms.greeter.enable = true requires osv.environment.dms.enable = true
        '';
      }

      # Greeter with configHome requires valid path
      {
        assertion = !cfg.environment.dms.greeter.enable ||
                   cfg.environment.dms.greeter.configHome == null ||
                   (lib.hasPrefix "/" cfg.environment.dms.greeter.configHome);
        message = ''
          OSV INVARIANT VIOLATION: Invalid greeter configHome
          osv.environment.dms.greeter.configHome must be an absolute path (start with /)
        '';
      }

      # ═══════════════════════════════════════════════════════════════════
      # USER CONFIGURATION INVARIANTS
      # ═══════════════════════════════════════════════════════════════════

      # If user is configured, username must be non-empty
      {
        assertion = cfg.users.primaryUser == null || cfg.users.primaryUser != "";
        message = ''
          OSV INVARIANT VIOLATION: Invalid user configuration
          osv.users.primaryUser cannot be an empty string
        '';
      }

      # ═══════════════════════════════════════════════════════════════════
      # APP STACK INVARIANTS
      # ═══════════════════════════════════════════════════════════════════

      # Gaming requires 32-bit support for many games
      {
        assertion = !cfg.apps.gaming.enable || cfg.hardware.gpu.enable32Bit;
        message = ''
          OSV INVARIANT VIOLATION: Gaming stack requirements
          osv.apps.gaming.enable = true requires osv.hardware.gpu.enable32Bit = true
          Many games and Proton require 32-bit graphics libraries.
        '';
      }

      # Gaming audio requirements (32-bit for games)
      {
        assertion = !cfg.apps.gaming.enable || !cfg.core.audio.enable || cfg.core.audio.support32Bit;
        message = ''
          OSV INVARIANT VIOLATION: Gaming audio requirements
          osv.apps.gaming.enable with audio requires osv.core.audio.support32Bit = true
          Many games require 32-bit audio libraries.
        '';
      }
    ];

    # ═══════════════════════════════════════════════════════════════════
    # WARNINGS (non-fatal but noteworthy)
    # ═══════════════════════════════════════════════════════════════════
    warnings = lib.flatten [
      # Core without networking is unusual
      (lib.optional (cfg.core.enable && !cfg.networking.enable)
        "OSV: core is enabled but networking is disabled. This is unusual for most systems.")

      # Gaming on Intel-only
      (lib.optional (cfg.apps.gaming.enable && gpuStack == "intel")
        "OSV: gaming stack enabled with Intel-only GPU. Performance may be limited for demanding games.")

      # Environment without core
      (lib.optional (cfg.environment.enable && !cfg.core.enable)
        "OSV: environment is enabled but core is disabled. Essential services may be missing.")

      # Laptop without power management consideration
      (lib.optional (facts.isLaptop && gpuStack == "nvidia-prime" && !cfg.hardware.gpu.nvidia.powerManagement)
        "OSV: Laptop with NVIDIA PRIME but power management disabled. Battery life may suffer.")

      # Discord is temporary
      (lib.optional cfg.apps.gaming.comms.discord
        "OSV: Discord is installed. This is a temporary bridge until Exom is ready.")

      # Greeter without configHome
      (lib.optional (cfg.environment.dms.greeter.enable && cfg.environment.dms.greeter.configHome == null)
        "OSV: DankGreeter enabled without configHome. Theme settings won't sync from user.")

      # Audio disabled but gaming enabled
      (lib.optional (cfg.apps.gaming.enable && !cfg.core.audio.enable)
        "OSV: Gaming stack enabled but audio is disabled. Games will have no sound.")
    ];
  };
}
