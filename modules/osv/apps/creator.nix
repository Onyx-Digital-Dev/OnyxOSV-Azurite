# OSV Creator SIP (Software Intent Profile)
#
# PURPOSE:
# "This system is ready for content creation workflows across graphics,
# digital art, 3D modeling, video editing, audio editing, and pipeline
# tooling without needing to discover missing tools mid-project."
#
# Creator SIP is *not* minimalism. Over-capability is intentional.
#
# BOUNDARY: This module provides creator SOFTWARE ONLY.
# It does NOT configure:
#   - GPU drivers or acceleration (see osv.hardware.gpu.*)
#   - Audio stack/PipeWire/JACK (see osv.core.audio.*)
#   - Display managers or sessions (see osv.environment.*)
#   - Kernel parameters or hardware-level settings
#
# COMPOSABILITY:
#   This SIP is designed to work alongside other SIPs (gaming, developer)
#   without conflicts. All packages are additive to environment.systemPackages.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.creator;

  # Shorthand for category enables
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
    # ═══════════════════════════════════════════════════════════════════════
    # GRAPHICS & DIGITAL ART
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Core tools for raster graphics, vector graphics, and digital painting.
    # These form the foundation of most visual content creation workflows.
    #

    # GIMP - GNU Image Manipulation Program
    # Industry-standard open-source raster graphics editor
    (lib.mkIf (gfx.enable && gfx.gimp) {
      environment.systemPackages = [ pkgs.gimp ];
    })

    # Inkscape - Professional vector graphics editor
    # SVG-native, suitable for logos, icons, illustrations
    (lib.mkIf (gfx.enable && gfx.inkscape) {
      environment.systemPackages = [ pkgs.inkscape ];
    })

    # Krita - Digital painting application
    # Optimized for illustrators, concept artists, comic artists
    (lib.mkIf (gfx.enable && gfx.krita) {
      environment.systemPackages = [ pkgs.krita ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # 3D MODELING & ANIMATION
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Full 3D content creation suite for modeling, sculpting, animation,
    # rendering, compositing, and video editing.
    #

    # Blender - Complete 3D creation suite
    # Modeling, rigging, animation, simulation, rendering, compositing
    (lib.mkIf (mdl.enable && mdl.blender) {
      environment.systemPackages = [ pkgs.blender ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # PHOTOGRAPHY & RAW WORKFLOW
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Professional photography workflow tools for RAW processing,
    # color grading, and non-destructive editing.
    #

    # darktable - Photography workflow application
    # RAW development, non-destructive editing, color management
    (lib.mkIf (pho.enable && pho.darktable) {
      environment.systemPackages = [ pkgs.darktable ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # VIDEO EDITING
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Non-linear video editing for content creators, filmmakers,
    # and anyone working with motion graphics.
    #

    # Kdenlive - KDE Non-Linear Video Editor
    # Multi-track timeline, effects, transitions, keyframes
    (lib.mkIf (vid.enable && vid.kdenlive) {
      environment.systemPackages = [ pkgs.kdenlive ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # AUDIO PRODUCTION
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Audio editing and digital audio workstation tools for podcasts,
    # music production, sound design, and audio post-production.
    #

    # Audacity - Multi-track audio editor
    # Recording, editing, effects processing, format conversion
    (lib.mkIf (aud.enable && aud.audacity) {
      environment.systemPackages = [ pkgs.audacity ];
    })

    # Ardour - Professional digital audio workstation
    # Multi-track recording, MIDI, mixing, mastering
    (lib.mkIf (aud.enable && aud.ardour) {
      environment.systemPackages = [ pkgs.ardour ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # PIPELINE TOOLS
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Command-line tools for media conversion, batch processing,
    # and automation of content creation workflows.
    #

    # ffmpeg - Complete multimedia framework
    # Decode, encode, transcode, mux, demux, stream, filter, play
    (lib.mkIf (pip.enable && pip.ffmpeg) {
      environment.systemPackages = [ pkgs.ffmpeg-full ];
    })

    # ImageMagick - Image processing toolkit
    # Convert, resize, composite, montage, animate images
    (lib.mkIf (pip.enable && pip.imagemagick) {
      environment.systemPackages = [ pkgs.imagemagick ];
    })

    # ExifTool - Metadata manipulation
    # Read, write, edit metadata in image, audio, video files
    (lib.mkIf (pip.enable && pip.exiftool) {
      environment.systemPackages = [ pkgs.exiftool ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # PIXEL ART TOOLS
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Specialized tools for pixel art creation, sprite editing,
    # and retro-style graphics workflows.
    #
    # 💜 This section was created with love for Cricket and Bean.
    # If you are reading this, know that the pixel art tools here
    # are included so that you and your sisters can create and explore.
    #

    # LibreSprite - Animated sprite editor & pixel art tool
    # FOSS fork of Aseprite, layers, frames, onion skinning
    (lib.mkIf (pix.enable && pix.libresprite) {
      environment.systemPackages = [ pkgs.libresprite ];
    })

    # mtPaint - Lightweight pixel painting program
    # Simple interface, palette-based, good for quick edits
    (lib.mkIf (pix.enable && pix.mtpaint) {
      environment.systemPackages = [ pkgs.mtpaint ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # COMMON CREATOR STACK
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Shared libraries and tools that benefit all creator workflows.
    #
    {
      environment.systemPackages = with pkgs; [
        # Color picker utility (useful across all graphics work)
        gpick
      ];
    }
  ]);
}
