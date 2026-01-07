# OSV Creator SIP
#
# Content creation tools for graphics, video, audio, and pipeline workflows.
# Does NOT configure GPU drivers, audio stacks, or display managers.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.creator;
  gfx = cfg.graphics;
  mdl = cfg.modeling;
  pho = cfg.photo;
  vid = cfg.video;
  aud = cfg.audio;
  pip = cfg.pipeline;
  pix = cfg.pixelart;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Graphics
    (lib.mkIf (gfx.enable && gfx.gimp) {
      environment.systemPackages = [ pkgs.gimp ];
    })
    (lib.mkIf (gfx.enable && gfx.inkscape) {
      environment.systemPackages = [ pkgs.inkscape ];
    })
    (lib.mkIf (gfx.enable && gfx.krita) {
      environment.systemPackages = [ pkgs.krita ];
    })

    # 3D Modeling
    (lib.mkIf (mdl.enable && mdl.blender) {
      environment.systemPackages = [ pkgs.blender ];
    })

    # Photography
    (lib.mkIf (pho.enable && pho.darktable) {
      environment.systemPackages = [ pkgs.darktable ];
    })

    # Video
    (lib.mkIf (vid.enable && vid.kdenlive) {
      environment.systemPackages = [ pkgs.kdenlive ];
    })

    # Audio
    (lib.mkIf (aud.enable && aud.audacity) {
      environment.systemPackages = [ pkgs.audacity ];
    })
    (lib.mkIf (aud.enable && aud.ardour) {
      environment.systemPackages = [ pkgs.ardour ];
    })

    # Pipeline
    (lib.mkIf (pip.enable && pip.ffmpeg) {
      environment.systemPackages = [ pkgs.ffmpeg-full ];
    })
    (lib.mkIf (pip.enable && pip.imagemagick) {
      environment.systemPackages = [ pkgs.imagemagick ];
    })
    (lib.mkIf (pip.enable && pip.exiftool) {
      environment.systemPackages = [ pkgs.exiftool ];
    })

    # Pixel Art - included for Cricket and Bean
    (lib.mkIf (pix.enable && pix.libresprite) {
      environment.systemPackages = [ pkgs.libresprite ];
    })
    (lib.mkIf (pix.enable && pix.mtpaint) {
      environment.systemPackages = [ pkgs.mtpaint ];
    })

    # Common
    {
      environment.systemPackages = [ pkgs.gpick ];
    }
  ]);
}
