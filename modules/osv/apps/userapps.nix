# OSV User Apps Module
#
# Provides base user applications.
# This is enabled by default for all hosts.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.userapps;
in
{
  config = lib.mkIf cfg.enable {
    # Browser
    programs.firefox.enable = lib.mkIf (cfg.browser == "firefox") true;

    environment.systemPackages = lib.mkMerge [
      # Chromium if selected
      (lib.mkIf (cfg.browser == "chromium") [ pkgs.chromium ])
    ];
  };
}
