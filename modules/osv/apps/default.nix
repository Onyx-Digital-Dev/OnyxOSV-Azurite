# OSV App Modules - Entry Point
#
# Provides application stack configuration via SIPs (Software Intent Profiles).
# SIPs are composable - ALL can be enabled simultaneously.
#
# Available SIPs:
#   - userapps: Base user applications
#   - gaming: Gaming launchers, tools, and performance utilities
#   - creator: Content creation tools (graphics, video, audio, pixel art)
#   - developer: Development tools, containers, editors, languages
#   - media: Media consumption (video, music, streaming clients)
#   - virtualization: Local VM management (QEMU/KVM, virt-manager)
#   - security: Trust verification, secrets management, inspection tools
#   - compute: Data science, numerical computing, ML experimentation
#
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
