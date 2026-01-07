# OSV Wayland Base Module
#
# Provides Wayland-only baseline configuration.
#
# ═══════════════════════════════════════════════════════════════════════════════
# WAYLAND STRATEGY
# ═══════════════════════════════════════════════════════════════════════════════
#
# OSV is Wayland-first. This means:
#   - No X11 server (services.xserver.enable = false)
#   - XWayland available for legacy X11 apps (Steam, older games)
#   - All session variables set for Wayland
#   - XDG portals configured for Wayland app integration
#
# X11 Compatibility:
#   - xwayland-satellite provides XWayland support
#   - NIXOS_OZONE_WL enables Wayland for Electron apps
#   - Steam/Proton games work via XWayland automatically
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
in
{
  config = lib.mkIf cfg.enable {
    # ═══════════════════════════════════════════════════════════════════
    # Display Server
    # ═══════════════════════════════════════════════════════════════════

    # Wayland-only: disable X11 server entirely
    # The compositor (Niri) handles display, not Xorg
    services.xserver.enable = false;

    # ═══════════════════════════════════════════════════════════════════
    # X11 Compatibility Layer
    # ═══════════════════════════════════════════════════════════════════

    # XWayland for X11 app compatibility (Steam, older games, etc.)
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    # ═══════════════════════════════════════════════════════════════════
    # Session Environment
    # ═══════════════════════════════════════════════════════════════════

    # These variables are critical for Wayland session detection
    environment.sessionVariables = {
      # Desktop identification
      XDG_CURRENT_DESKTOP = cfg.session;
      XDG_SESSION_DESKTOP = cfg.session;
      XDG_SESSION_TYPE = "wayland";

      # Enable Wayland for Electron/Chromium apps (Discord, VS Code, etc.)
      NIXOS_OZONE_WL = "1";
    };

    # ═══════════════════════════════════════════════════════════════════
    # XDG Portals
    # ═══════════════════════════════════════════════════════════════════

    # Portals provide sandboxed app access to system services
    # (file chooser, screen sharing, etc.)
    xdg.portal = lib.mkIf cfg.portals.enable {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk    # GTK file dialogs
        xdg-desktop-portal-gnome  # Screen sharing, etc.
      ] ++ cfg.portals.extraPortals;
    };

    # ═══════════════════════════════════════════════════════════════════
    # Security
    # ═══════════════════════════════════════════════════════════════════

    # Polkit for privilege escalation dialogs
    security.polkit.enable = true;
  };
}
