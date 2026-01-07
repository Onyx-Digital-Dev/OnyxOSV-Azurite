# OSV Library - Entry Point
#
# Aggregates all OSV library functions.
# These are pure helpers - no runtime probing, no side effects.
{ lib }:

{
  # Assertion helpers for invariant enforcement
  asserts = import ./asserts.nix { inherit lib; };

  # Default values and constants
  defaults = import ./defaults.nix { inherit lib; };

  # Module construction helper
  mkModule = import ./mkModule.nix { inherit lib; };
}
