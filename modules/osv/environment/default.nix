# OSV Environment Modules - Entry Point
#
# Provides desktop environment configuration.
# Currently supports: Niri + DankMaterialShell
{ config, lib, pkgs, ... }:

{
  imports = [
    ./wayland-base.nix
    ./sessions.nix
    ./dms-niri.nix
  ];
}
