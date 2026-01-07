# OSV Media Module
#
# Provides media consumption tools:
# - Video players
# - Audio players
# - Image viewers
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.media;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # Video players
      lib.optionals cfg.video [
        mpv
        vlc
      ]

      # Audio players
      ++ lib.optionals cfg.audio [
        rhythmbox
      ]

      # Image viewers
      ++ lib.optionals cfg.images [
        eog
        feh
      ];
  };
}
