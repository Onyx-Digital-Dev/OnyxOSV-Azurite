# OSV Sessions Module
#
# Provides session/compositor configuration.
# Session selection is ENUM-based via osv.environment.session.
#
# ═══════════════════════════════════════════════════════════════════════════════
# SESSION DISCOVERY
# ═══════════════════════════════════════════════════════════════════════════════
#
# How sessions are discovered:
#   1. programs.niri.enable installs Niri and its .desktop file
#   2. services.displayManager.sessionPackages adds Niri to session list
#   3. DankGreeter reads session list from /share/wayland-sessions/
#   4. User selects session in greeter, greeter launches it
#
# This is the ONLY mechanism for session discovery.
# NO manual .desktop files. NO environment hacks.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.environment;
  isNiri = cfg.session == "niri";
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════
    # Niri Compositor
    # ═══════════════════════════════════════════════════════════════════
    (lib.mkIf isNiri {
      # Enable Niri compositor
      # This installs the niri package and creates the .desktop session file
      programs.niri.enable = true;

      # Register Niri as an available session for display managers
      # DankGreeter uses this to populate its session selector
      services.displayManager.sessionPackages = [ pkgs.niri ];
    })

    # ═══════════════════════════════════════════════════════════════════
    # Future Compositors
    # ═══════════════════════════════════════════════════════════════════
    # To add a new compositor:
    # 1. Add it to osv.environment.session enum in options.nix
    # 2. Add a conditional block here following the Niri pattern
    # 3. Update dms-niri.nix or create dms-<compositor>.nix
    # 4. Test session discovery in DankGreeter
  ]);
}
