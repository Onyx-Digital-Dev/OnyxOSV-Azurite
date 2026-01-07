# OSV Wayland Base Module
#
# Provides Wayland-only baseline configuration.
# OSV is Wayland-first; X11 is only for compatibility (XWayland).
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
in
{
  config = lib.mkIf cfg.enable {
    # Wayland-only: disable X11 server
    services.xserver.enable = false;

    # XWayland for X11 app compatibility
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    # Session environment variables
    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = cfg.session;
      XDG_SESSION_DESKTOP = cfg.session;
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    # XDG portals for Wayland apps
    xdg.portal = lib.mkIf cfg.portals.enable {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ] ++ cfg.portals.extraPortals;
    };

    # Polkit for privilege escalation
    security.polkit.enable = true;
  };
}
