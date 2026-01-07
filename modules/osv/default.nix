# OSV Module System - Entry Point
#
# This module imports all OSV submodules.
# The option schema is defined in options.nix.
# Each submodule implements behavior based on options.
{ config, lib, pkgs, ... }:

{
  imports = [
    # Option definitions (SINGLE SOURCE)
    ./options.nix

    # Core modules
    ./core.nix
    ./networking.nix
    ./users.nix

    # Hardware modules
    ./hardware

    # Environment modules
    ./environment

    # App stack modules
    ./apps

    # Meta modules (invariants, logging)
    ./meta/invariants.nix
    ./meta/logging.nix
  ];
}
