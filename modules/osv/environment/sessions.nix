# OSV Sessions Module
#
# Provides session/compositor configuration.
# Session selection is ENUM-based via osv.environment.session.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
  isNiri = cfg.session == "niri";
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Niri compositor
    (lib.mkIf isNiri {
      programs.niri.enable = true;

      # Ensure Niri session appears in display manager session list
      services.displayManager.sessionPackages = [ pkgs.niri ];
    })

    # Future: other compositors can be added here
  ]);
}
