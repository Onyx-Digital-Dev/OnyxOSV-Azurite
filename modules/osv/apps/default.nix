# OSV App Modules - Entry Point
#
# Provides application stack configuration.
# App stacks are additive - multiple can be enabled.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./userapps.nix
    ./gaming.nix
    ./creator.nix
    ./developer.nix
    ./media.nix
  ];
}
