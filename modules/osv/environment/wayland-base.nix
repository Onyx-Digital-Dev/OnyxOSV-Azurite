# OSV Wayland Base Module
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver.enable = false;

    environment.systemPackages = with pkgs; [
      # X11 compatibility
      xwayland-satellite

      # Terminals (ghostty default, alacritty backup)
      ghostty
      alacritty

      # File managers
      yazi
    ];

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = cfg.session;
      XDG_SESSION_DESKTOP = cfg.session;
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      TERMINAL = "ghostty";
    };

    # Thunar with goodies
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.tumbler.enable = true;
    services.gvfs.enable = true;

    xdg.portal = lib.mkIf cfg.portals.enable {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ] ++ cfg.portals.extraPortals;
    };

    security.polkit.enable = true;
  };
}
