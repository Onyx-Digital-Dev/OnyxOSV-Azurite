# OSV App Modules
{ config, lib, pkgs, ... }:

{
  imports = [
    ./userapps.nix
    ./gaming.nix
    ./creator.nix
    ./developer.nix
    ./media.nix
    ./virtualization.nix
    ./security.nix
    ./compute.nix
  ];
}
