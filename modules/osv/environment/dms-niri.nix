# OSV DMS + Niri Integration Module
#
# Provides DankMaterialShell + Niri integration.
# This is the primary OSV desktop environment stack.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
  dmsCfg = cfg.dms;
  greeterCfg = dmsCfg.greeter;
  isNiri = cfg.session == "niri";
in
{
  config = lib.mkIf (cfg.enable && dmsCfg.enable && isNiri) (lib.mkMerge [
    # DankMaterialShell
    {
      programs.dankMaterialShell = {
        enable = true;
        systemd = {
          enable = dmsCfg.systemd;
          restartIfChanged = true;
        };
      };
    }

    # DankGreeter
    (lib.mkIf greeterCfg.enable {
      programs.dankMaterialShell.greeter = {
        enable = true;

        compositor = {
          name = "niri";
        };

        configHome = greeterCfg.configHome;
        configFiles = greeterCfg.configFiles;

        logs = {
          save = greeterCfg.logs.save;
          path = greeterCfg.logs.path;
        };
      };
    })
  ]);
}
