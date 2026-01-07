# OSV Assertion Helpers
#
# Provides assertion utilities for enforcing invariants at evaluation time.
# Invalid configurations MUST fail at evaluation, not at boot or runtime.
{ lib }:

{
  # Assert that exactly one option in a list is enabled
  # Usage: assertExactlyOne "environment" [ cfg.niri.enable cfg.hyprland.enable ]
  assertExactlyOne = name: enableList:
    let
      enabledCount = lib.count (x: x) enableList;
    in
    lib.assertMsg (enabledCount == 1)
      "OSV: Exactly one ${name} must be enabled, but ${toString enabledCount} are enabled";

  # Assert that at most one option in a list is enabled
  assertAtMostOne = name: enableList:
    let
      enabledCount = lib.count (x: x) enableList;
    in
    lib.assertMsg (enabledCount <= 1)
      "OSV: At most one ${name} may be enabled, but ${toString enabledCount} are enabled";

  # Assert a dependency: if A is enabled, B must also be enabled
  # Usage: assertDependency "gaming" "gpu" cfg.apps.gaming.enable cfg.hardware.gpu.enable
  assertDependency = dependent: dependency: depEnabled: reqEnabled:
    lib.assertMsg (!depEnabled || reqEnabled)
      "OSV: ${dependent} requires ${dependency} to be enabled";

  # Assert mutual exclusivity between two options
  assertMutuallyExclusive = optA: optB: enabledA: enabledB:
    lib.assertMsg (!(enabledA && enabledB))
      "OSV: ${optA} and ${optB} are mutually exclusive";

  # Assert that a value is one of the allowed values (for runtime validation)
  assertOneOf = name: value: allowed:
    lib.assertMsg (lib.elem value allowed)
      "OSV: ${name} must be one of [${lib.concatStringsSep ", " (map toString allowed)}], got: ${toString value}";

  # Assert GPU stack is valid
  assertValidGpuStack = stack:
    let
      validStacks = [ "intel" "amd" "nvidia" "nvidia-prime" ];
    in
    lib.assertMsg (lib.elem stack validStacks)
      "OSV: osv.hardware.gpu.stack must be one of [${lib.concatStringsSep ", " validStacks}], got: ${stack}";

  # Assert facts are consistent with configuration
  # Usage in a module: config = lib.mkIf (osvAsserts.assertFactsConsistent facts cfg) { ... }
  assertPrimeRequiresHybridGpu = facts: gpuStack:
    lib.assertMsg (gpuStack != "nvidia-prime" || facts.gpu == "hybrid")
      "OSV: nvidia-prime stack requires facts.gpu = \"hybrid\", got: ${facts.gpu}";
}
