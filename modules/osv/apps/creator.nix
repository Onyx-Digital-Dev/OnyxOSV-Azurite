# OSV Creator Module
#
# Provides creative production tools:
# - Graphics (Krita, GIMP, Inkscape, Blender)
# - Video (Kdenlive, Shotcut)
# - Audio (Ardour, Audacity)
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.creator;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # Graphics
      lib.optionals cfg.graphics [
        krita
        gimp
        inkscape
        blender
      ]

      # Video
      ++ lib.optionals cfg.video [
        kdenlive
        shotcut
        ffmpeg
        mediainfo
      ]

      # Audio
      ++ lib.optionals cfg.audio [
        ardour
        audacity
        lmms
        lsp-plugins
        calf
      ];
  };
}
