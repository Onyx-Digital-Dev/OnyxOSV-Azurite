# OSV User Apps Module
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.userapps;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox.enable = lib.mkIf (cfg.browser == "firefox") true;

    environment.systemPackages = lib.mkMerge [
      (lib.mkIf (cfg.browser == "brave") [ pkgs.brave ])
      (lib.mkIf (cfg.browser == "chromium") [ pkgs.chromium ])
    ];
  };
}
