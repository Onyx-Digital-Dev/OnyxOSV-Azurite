# OSV Gaming SIP (Software Intent Profile)
#
# BOUNDARY: This module provides gaming SOFTWARE ONLY.
# It does NOT configure:
#   - GPU hardware (see osv.hardware.gpu.*)
#   - Display/environment (see osv.environment.*)
#   - System-level optimizations beyond GameMode
#
# TIER STRUCTURE:
#   Tier 1 (MUST SHIP): Steam, Heroic, Lutris, OBS Studio, Discord
#   Tier 2 (default on): ProtonUp-Qt, MangoHud, Gamescope, GameMode
#   Tier 3 (optional):   vkBasalt, Goverlay, winetricks
#
# COMPOSABILITY:
#   This SIP is designed to work alongside other SIPs (creator, developer)
#   without conflicts. All packages are additive to environment.systemPackages.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.gaming;
  t1 = cfg.tier1;
  t2 = cfg.tier2;
  t3 = cfg.tier3;

  # Helper to wrap command if it exists
  wrapIfPresent = name: ''
    if command -v "${name}" >/dev/null 2>&1; then
      set -- "${name}" "$@"
    fi
  '';

  # ═══════════════════════════════════════════════════════════════════════════
  # OSV Wrappers
  # ═══════════════════════════════════════════════════════════════════════════
  #
  # osv-game: Universal game wrapper applying GPU offload + performance tools
  # osv-steam: Steam-specific wrapper for consistent launch behavior
  #
  # These wrappers integrate with osv.hardware.gpu.wrapperName for GPU offload.
  # ═══════════════════════════════════════════════════════════════════════════

  # OSV game wrapper - applies all performance layers
  osvGame = pkgs.writeShellScriptBin "osv-game" ''
    set -euo pipefail

    # Avoid bwrap chdir failures
    cd "$HOME" 2>/dev/null || cd /tmp

    ${lib.optionalString t2.gamemode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString t2.mangohud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}

    exec "$@"
  '';

  # OSV Steam wrapper - consistent Steam launch with all layers
  osvSteam = pkgs.writeShellScriptBin "osv-steam" ''
    set -euo pipefail

    cd "$HOME" 2>/dev/null || cd /tmp

    ${lib.optionalString t2.gamemode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString t2.mangohud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}

    exec ${pkgs.steam}/bin/steam "$@"
  '';

  # Steam command override (ensures osv-steam is used system-wide)
  steamCmd = pkgs.writeShellScriptBin "steam" ''
    set -euo pipefail
    cd "$HOME" 2>/dev/null || cd /tmp
    exec osv-steam "$@"
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════════
    # TIER 1: MUST SHIP
    # ═══════════════════════════════════════════════════════════════════════

    # Steam
    (lib.mkIf t1.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = t1.steam.remotePlayFirewall;
      };

      hardware.steam-hardware.enable = true;

      # OSV Steam wrappers
      environment.systemPackages = [
        osvGame
        osvSteam
        steamCmd
        pkgs.steam-run  # For running non-Steam games
      ];

      # OSV Steam desktop entry (uses wrapper)
      environment.etc."xdg/applications/steam.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=Steam
        Comment=Steam (OSV policy wrapper)
        Exec=osv-steam %U
        TryExec=osv-steam
        Icon=steam
        Terminal=false
        Categories=Game;Network;
        StartupNotify=true
        StartupWMClass=steam
      '';
    })

    # Heroic (Epic/GOG launcher)
    (lib.mkIf t1.heroic {
      environment.systemPackages = [ pkgs.heroic ];
    })

    # Lutris (universal game launcher)
    (lib.mkIf t1.lutris {
      environment.systemPackages = [ pkgs.lutris ];
    })

    # OBS Studio (streaming/recording)
    (lib.mkIf t1.obs {
      environment.systemPackages = [ pkgs.obs-studio ];
    })

    # Discord (gaming communications)
    (lib.mkIf t1.discord {
      environment.systemPackages = [ pkgs.discord ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # TIER 2: DEFAULT ON
    # ═══════════════════════════════════════════════════════════════════════

    # GameMode (performance optimizer)
    (lib.mkIf t2.gamemode {
      programs.gamemode.enable = true;
    })

    # MangoHud (performance overlay)
    (lib.mkIf t2.mangohud {
      environment.systemPackages = [ pkgs.mangohud ];
    })

    # Gamescope (compositor for games)
    (lib.mkIf t2.gamescope {
      environment.systemPackages = [ pkgs.gamescope ];
    })

    # ProtonUp-Qt (Proton version manager)
    (lib.mkIf t2.protonup {
      environment.systemPackages = [ pkgs.protonup-qt ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # TIER 3: OPTIONAL
    # ═══════════════════════════════════════════════════════════════════════

    # vkBasalt (Vulkan post-processing layer)
    (lib.mkIf t3.vkbasalt {
      environment.systemPackages = [ pkgs.vkbasalt ];
    })

    # GOverlay (MangoHud/vkBasalt configurator GUI)
    (lib.mkIf t3.goverlay {
      environment.systemPackages = [ pkgs.goverlay ];
    })

    # winetricks (Wine configuration tool)
    (lib.mkIf t3.winetricks {
      environment.systemPackages = [ pkgs.winetricks ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # Common Gaming Stack
    # ═══════════════════════════════════════════════════════════════════════
    {
      # Vulkan tools for diagnostics
      environment.systemPackages = [ pkgs.vulkan-tools ];

      # Unfree packages required for Steam/Discord
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    }
  ]);
}
