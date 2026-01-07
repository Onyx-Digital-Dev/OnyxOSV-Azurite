# OSV Hardware Modules - Entry Point
#
# Imports all hardware-related modules.
# Hardware modules configure drivers and hardware-specific behavior.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./gpu
    ./display
  ];
}
