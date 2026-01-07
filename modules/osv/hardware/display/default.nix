# OSV Display Modules - Entry Point
#
# Provides display-specific configuration.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./lspcon.nix
  ];
}
