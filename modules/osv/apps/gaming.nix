# OSV Gaming SIP
#
# Gaming software stack. Does NOT configure GPU hardware or system optimizations.
# Tier 1: Steam, Heroic, Lutris, OBS, Discord
# Tier 2: ProtonUp-Qt, MangoHud, Gamescope, GameMode
# Tier 3: vkBasalt, Goverlay, winetricks
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.gaming;
  t1 = cfg.tier1;
  t2 = cfg.tier2;
  t3 = cfg.tier3;

  wrapIfPresent = name: ''
    if command -v "${name}" >/dev/null 2>&1; then
      set -- "${name}" "$@"
    fi
  '';

  osvGame = pkgs.writeShellScriptBin "osv-game" ''
    set -euo pipefail
    cd "$HOME" 2>/dev/null || cd /tmp
    ${lib.optionalString t2.gamemode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString t2.mangohud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}
    exec "$@"
  '';

  osvSteam = pkgs.writeShellScriptBin "osv-steam" ''
    set -euo pipefail
    cd "$HOME" 2>/dev/null || cd /tmp
    ${lib.optionalString t2.gamemode (wrapIfPresent "gamemoderun")}
    ${lib.optionalString t2.mangohud (wrapIfPresent "mangohud")}
    ${lib.optionalString (cfg.gpuWrapper != "") (wrapIfPresent cfg.gpuWrapper)}
    exec ${pkgs.steam}/bin/steam "$@"
  '';

  steamCmd = pkgs.writeShellScriptBin "steam" ''
    set -euo pipefail
    cd "$HOME" 2>/dev/null || cd /tmp
    exec osv-steam "$@"
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Tier 1
    (lib.mkIf t1.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = t1.steam.remotePlayFirewall;
      };
      hardware.steam-hardware.enable = true;
      environment.systemPackages = [ osvGame osvSteam steamCmd pkgs.steam-run ];
      environment.etc."xdg/applications/steam.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=Steam
        Comment=Steam (OSV wrapper)
        Exec=osv-steam %U
        TryExec=osv-steam
        Icon=steam
        Terminal=false
        Categories=Game;Network;
        StartupNotify=true
        StartupWMClass=steam
      '';
    })
    (lib.mkIf t1.heroic { environment.systemPackages = [ pkgs.heroic ]; })
    (lib.mkIf t1.lutris { environment.systemPackages = [ pkgs.lutris ]; })
    (lib.mkIf t1.obs { environment.systemPackages = [ pkgs.obs-studio ]; })
    (lib.mkIf t1.discord { environment.systemPackages = [ pkgs.discord ]; })

    # Tier 2
    (lib.mkIf t2.gamemode { programs.gamemode.enable = true; })
    (lib.mkIf t2.mangohud { environment.systemPackages = [ pkgs.mangohud ]; })
    (lib.mkIf t2.gamescope { environment.systemPackages = [ pkgs.gamescope ]; })
    (lib.mkIf t2.protonup { environment.systemPackages = [ pkgs.protonup-qt ]; })

    # Tier 3
    (lib.mkIf t3.vkbasalt { environment.systemPackages = [ pkgs.vkbasalt ]; })
    (lib.mkIf t3.goverlay { environment.systemPackages = [ pkgs.goverlay ]; })
    (lib.mkIf t3.winetricks { environment.systemPackages = [ pkgs.winetricks ]; })

    # Common
    {
      environment.systemPackages = [ pkgs.vulkan-tools ];
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    }
  ]);
}
