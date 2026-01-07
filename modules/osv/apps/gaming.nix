# OSV Gaming Module
#
# Provides gaming stack:
# - Steam
# - Heroic (Epic/GOG)
# - GameMode
# - MangoHud
# - OSV wrappers (osv-game, osv-steam)
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.gaming;

  # Helper to wrap command if it exists
  wrapIfPresent = name: ''
    if command -v "${name}" >/dev/null 2>&1; then
      set -- "${name}" "$@"
    fi
  '';

  # OSV game wrapper
  osvGame = pkgs.writeShellScriptBin "osv-game" ''
    set -euo pipefail

    # Avoid bwrap chdir failures
    cd "$HOME" 2>/dev/null || cd /tmp

    ${lib.optionalString cfg.enableGameMode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString cfg.enableMangoHud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}

    exec "$@"
  '';

  # OSV Steam wrapper
  osvSteam = pkgs.writeShellScriptBin "osv-steam" ''
    set -euo pipefail

    cd "$HOME" 2>/dev/null || cd /tmp

    ${lib.optionalString cfg.enableGameMode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString cfg.enableMangoHud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}

    exec ${pkgs.steam}/bin/steam "$@"
  '';

  # Steam command override (ensures osv-steam is used)
  steamCmd = pkgs.writeShellScriptBin "steam" ''
    set -euo pipefail
    cd "$HOME" 2>/dev/null || cd /tmp
    exec osv-steam "$@"
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Steam
    (lib.mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = cfg.steam.remotePlayFirewall;
      };

      hardware.steam-hardware.enable = true;

      # OSV Steam wrappers
      environment.systemPackages = [
        osvGame
        osvSteam
        steamCmd
      ];

      # OSV Steam desktop entry
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

    # Heroic
    (lib.mkIf cfg.heroic {
      environment.systemPackages = [ pkgs.heroic ];
    })

    # GameMode
    (lib.mkIf cfg.enableGameMode {
      programs.gamemode.enable = true;
    })

    # MangoHud
    (lib.mkIf cfg.enableMangoHud {
      environment.systemPackages = [ pkgs.mangohud ];
    })

    # Tools
    {
      environment.systemPackages = with pkgs;
        [ steam-run vulkan-tools ]
        ++ lib.optionals cfg.tools.gamescope [ gamescope ]
        ++ lib.optionals cfg.tools.protonup [ protonup-qt ];
    }

    # Comms
    {
      environment.systemPackages = with pkgs;
        lib.optionals cfg.comms.discord [ discord ]
        ++ lib.optionals cfg.comms.obs [ obs-studio ];
    }

    # Unfree for Steam/Discord
    {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    }
  ]);
}
