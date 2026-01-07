# OSV Virtualization SIP
#
# Local VM management tools. Does NOT configure passthrough, bridges, or kernel modules.
# Excludes: containers (Developer SIP), cloud orchestration.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.virtualization;
in
{
  config = lib.mkIf cfg.enable {
    # libvirtd required for virt-manager; no auto-start, no bridges
    virtualisation.libvirtd.enable = true;

    environment.systemPackages = with pkgs; [
      virt-manager
      gnome-boxes
      libvirt
      virt-viewer
      qemu
      vagrant
      spice-gtk
    ];
  };
}
