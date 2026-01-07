# OSV Invariants Module
#
# Enforces OSV invariants at evaluation time.
# Invalid configurations MUST fail here, not at boot.
{ config, lib, pkgs, osvLib, ... }:

let
  cfg = config.osv;
  facts = cfg.facts;
  gpuStack = cfg.hardware.gpu.stack;
in
{
  config = {
    assertions = [
      # PRIME requires hybrid GPU
      {
        assertion = gpuStack != "nvidia-prime" || facts.gpu == "hybrid";
        message = ''
          OSV INVARIANT VIOLATION:
          osv.hardware.gpu.stack = "nvidia-prime" requires osv.facts.gpu = "hybrid"
          Current facts.gpu = "${facts.gpu}"
        '';
      }

      # nvidia stack requires nvidia or hybrid GPU
      {
        assertion = gpuStack != "nvidia" || (facts.gpu == "nvidia" || facts.gpu == "hybrid");
        message = ''
          OSV INVARIANT VIOLATION:
          osv.hardware.gpu.stack = "nvidia" requires osv.facts.gpu = "nvidia" or "hybrid"
          Current facts.gpu = "${facts.gpu}"
        '';
      }

      # Environment requires session to be selected
      {
        assertion = !cfg.environment.enable || cfg.environment.session != null;
        message = ''
          OSV INVARIANT VIOLATION:
          osv.environment.enable = true requires osv.environment.session to be set
        '';
      }

      # DMS requires environment to be enabled
      {
        assertion = !cfg.environment.dms.enable || cfg.environment.enable;
        message = ''
          OSV INVARIANT VIOLATION:
          osv.environment.dms.enable = true requires osv.environment.enable = true
        '';
      }

      # Greeter requires DMS
      {
        assertion = !cfg.environment.dms.greeter.enable || cfg.environment.dms.enable;
        message = ''
          OSV INVARIANT VIOLATION:
          osv.environment.dms.greeter.enable = true requires osv.environment.dms.enable = true
        '';
      }
    ];

    # Warnings for common misconfigurations
    warnings = lib.flatten [
      (lib.optional (cfg.core.enable && !cfg.networking.enable)
        "OSV: core is enabled but networking is disabled. This is unusual.")

      (lib.optional (cfg.apps.gaming.enable && gpuStack == "intel")
        "OSV: gaming stack is enabled with Intel-only GPU. Performance may be limited.")

      (lib.optional (cfg.environment.enable && !cfg.core.enable)
        "OSV: environment is enabled but core is disabled. This may cause issues.")
    ];
  };
}
