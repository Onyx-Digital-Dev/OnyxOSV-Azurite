# OSV User Apps Module
#
# Common user applications included on all OSV systems.
# Add applications here in the form: [ pkgs.packagename ]
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

      # ═══════════════════════════════════════════════════════════════════
      # USER APPLICATIONS
      # Add packages here: [ pkgs.packagename ]
      # ═══════════════════════════════════════════════════════════════════
      [ pkgs.bitwarden-desktop ]
      [ pkgs.bitwarden-cli ]
    ];
  };
}
