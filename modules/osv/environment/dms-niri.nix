# OSV DMS + Niri Integration Module
#
# Provides DankMaterialShell + Niri integration.
# This is the primary OSV desktop environment stack.
#
# ═══════════════════════════════════════════════════════════════════════════════
# SESSION CONTRACT
# ═══════════════════════════════════════════════════════════════════════════════
#
# Boot Path (SINGLE, DETERMINISTIC):
#   1. systemd starts DankGreeter on greeter tty
#   2. DankGreeter discovers Niri session via XDG sessionPackages
#   3. User authenticates, DankGreeter launches Niri
#   4. Niri starts, DankMaterialShell activates via systemd user target
#   5. DMS provides shell UI within Niri compositor
#
# Session Discovery:
#   - Niri .desktop file in /share/wayland-sessions/ (via programs.niri.enable)
#   - DankGreeter reads from services.displayManager.sessionPackages
#   - NO manual .desktop files, NO environment variable hacks
#
# Invariants:
#   - EXACTLY ONE display manager (DankGreeter)
#   - EXACTLY ONE compositor session (Niri)
#   - DMS activates WITHIN Niri, not alongside it
#   - No tty2 double-session issues
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
  dmsCfg = cfg.dms;
  greeterCfg = dmsCfg.greeter;
  isNiri = cfg.session == "niri";
in
{
  config = lib.mkIf (cfg.enable && dmsCfg.enable && isNiri) (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════
    # DankMaterialShell - Shell layer (runs WITHIN Niri)
    # ═══════════════════════════════════════════════════════════════════
    {
      programs.dankMaterialShell = {
        enable = true;
        systemd = {
          # Activate via systemd user target (graphical-session.target)
          enable = dmsCfg.systemd;
          # Restart on config changes for live updates
          restartIfChanged = true;
        };
      };
    }

    # ═══════════════════════════════════════════════════════════════════
    # DankGreeter - Display manager (launches Niri session)
    # ═══════════════════════════════════════════════════════════════════
    (lib.mkIf greeterCfg.enable {
      programs.dankMaterialShell.greeter = {
        enable = true;

        # Compositor for greeter itself (NOT the user session)
        # Greeter runs in its own Niri instance, then hands off to user session
        compositor = {
          name = "niri";
          # customConfig left empty - use Niri defaults for greeter
        };

        # Theme sync from user home
        configHome = greeterCfg.configHome;
        configFiles = greeterCfg.configFiles;

        # Diagnostic logging
        logs = {
          save = greeterCfg.logs.save;
          path = greeterCfg.logs.path;
        };
      };
    })

    # ═══════════════════════════════════════════════════════════════════
    # Session stability measures
    # ═══════════════════════════════════════════════════════════════════
    {
      # Prevent tty2 double-session issues during boot
      # DankGreeter manages the session, not getty
      systemd.services."getty@tty2".enable = lib.mkDefault false;
      systemd.services."autovt@tty2".enable = lib.mkDefault false;
    }
  ]);
}
