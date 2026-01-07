# OSV Virtualization SIP (Software Intent Profile)
#
# PURPOSE:
# "This workstation is ready to create, run, and manage local virtual
# machines for development testing, OS experimentation, compatibility
# verification, and isolated lab environments."
#
# CAPABILITIES:
#   - Run local virtual machines via QEMU/KVM userspace tools
#   - Manage VM lifecycle through graphical and CLI interfaces
#   - Create, convert, and inspect disk images
#   - Snapshot and clone virtual machines
#   - Share files between host and guest via standard mechanisms
#   - Use Vagrant for reproducible development environments
#
# BOUNDARY: This module provides VM userspace tools ONLY.
# It does NOT configure:
#   - Hardware passthrough (VFIO, GPU passthrough, IOMMU policy)
#   - Network bridges or infrastructure-level networking
#   - Kernel modules (assumes KVM is available)
#   - Remote hypervisor management
#   - Auto-starting VMs
#
# EXPLICIT EXCLUSIONS:
#   - Containers (belongs to Developer SIP)
#   - Cloud orchestration (Kubernetes, OpenStack, cluster management)
#
# SERVICE JUSTIFICATION:
#   libvirtd is enabled because virt-manager requires it. This is acceptable
#   because it is explicitly scoped, user-initiated, and does not alter
#   system behavior until the user creates VMs.
#
# COMPOSABILITY:
#   This SIP is designed to work alongside all other SIPs without conflicts.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.virtualization;
in
{
  config = lib.mkIf cfg.enable {
    # ═══════════════════════════════════════════════════════════════════════
    # LIBVIRT SERVICE
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Required for virt-manager functionality.
    # Configuration is minimal and default-safe:
    #   - No auto-starting VMs
    #   - No network bridges created
    #   - No QEMU user override
    #
    virtualisation.libvirtd = {
      enable = true;
      # Do not create default network bridge
      # Users who need networking can configure it explicitly
    };

    # ═══════════════════════════════════════════════════════════════════════
    # VM MANAGEMENT TOOLS
    # ═══════════════════════════════════════════════════════════════════════
    environment.systemPackages = with pkgs; [
      # ─────────────────────────────────────────────────────────────────────
      # Graphical VM Management
      # ─────────────────────────────────────────────────────────────────────
      virt-manager        # Full-featured VM management GUI
      gnome-boxes         # Simple VM creation and management

      # ─────────────────────────────────────────────────────────────────────
      # CLI VM Management
      # ─────────────────────────────────────────────────────────────────────
      libvirt             # virsh and other CLI tools
      virt-viewer         # Remote VM display viewer

      # ─────────────────────────────────────────────────────────────────────
      # QEMU Userspace Tools
      # ─────────────────────────────────────────────────────────────────────
      qemu                # QEMU emulator and virtualizer

      # ─────────────────────────────────────────────────────────────────────
      # Disk Image Utilities
      # ─────────────────────────────────────────────────────────────────────
      # qemu-img is included with qemu package
      # Provides: create, convert, inspect, snapshot disk images

      # ─────────────────────────────────────────────────────────────────────
      # Development Environment Reproducibility
      # ─────────────────────────────────────────────────────────────────────
      vagrant             # Reproducible development environments

      # ─────────────────────────────────────────────────────────────────────
      # Utilities
      # ─────────────────────────────────────────────────────────────────────
      spice-gtk           # SPICE client for better VM display
    ];
  };
}
