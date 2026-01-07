# OSV LSPCON Display Module
#
# Provides workarounds for LSPCON display adapters.
# LSPCON (Level Shifter and Protocol Converter) is used in some
# laptop display configurations.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.hardware.display.lspcon;
in
{
  config = lib.mkIf cfg.enable {
    # LSPCON-specific kernel parameters or configuration
    # will be added here as needed
  };
}
