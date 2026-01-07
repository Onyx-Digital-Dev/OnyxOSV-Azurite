# OSV Logging Module
#
# Provides diagnostic logging for OSV.
# This helps with debugging and audit trails.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.meta.logging;
in
{
  config = lib.mkIf cfg.enable {
    # OSV diagnostic script
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "osv-diag" ''
        echo "═══════════════════════════════════════════════════════════════"
        echo "OSV DIAGNOSTIC REPORT"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Hostname: $(hostname)"
        echo "NixOS Version: $(nixos-version)"
        echo "Kernel: $(uname -r)"
        echo ""
        echo "GPU Info:"
        ${pkgs.pciutils}/bin/lspci | grep -iE "(vga|3d|display)" || echo "  No GPU detected"
        echo ""
        echo "Active Display Sessions:"
        loginctl list-sessions 2>/dev/null || echo "  loginctl unavailable"
        echo ""
        echo "Wayland Status:"
        echo "  XDG_SESSION_TYPE: ''${XDG_SESSION_TYPE:-unset}"
        echo "  WAYLAND_DISPLAY: ''${WAYLAND_DISPLAY:-unset}"
        echo ""
        echo "NVIDIA Status:"
        if command -v nvidia-smi >/dev/null 2>&1; then
          nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || echo "  nvidia-smi failed"
        else
          echo "  nvidia-smi not available"
        fi
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
      '')
    ];
  };
}
