# OSV Media SIP (Software Intent Profile)
#
# PURPOSE:
# "This system is ready for high-quality media consumption and
# organization on a workstation."
#
# Media SIP is about:
# • watching video
# • listening to music
# • organizing media libraries
# • streaming from existing servers
#
# Media SIP is NOT:
# • content creation (see Creator SIP)
# • recording or capture
# • live streaming
# • media automation
# • self-hosted media servers
#
# BOUNDARY: This module provides media consumption SOFTWARE ONLY.
# It does NOT configure:
#   - PipeWire, WirePlumber, JACK, or audio routing (see osv.core.audio.*)
#   - GPU drivers, VAAPI, PRIME, or hardware acceleration (see osv.hardware.gpu.*)
#   - Display managers or sessions (see osv.environment.*)
#   - Kernel parameters or capture devices
#
# EXPLICIT EXCLUSIONS (DO NOT INCLUDE):
#   - Kodi
#   - cmus
#   - Jellyfin server (services.jellyfin)
#   - *arr suite (Radarr, Sonarr, Lidarr, Prowlarr)
#   - Any download automation services
#   - Any background daemons
#
# COMPOSABILITY:
#   This SIP is designed to work alongside other SIPs (gaming, creator, developer)
#   without conflicts. Package overlap is intentional and acceptable.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.media;

  # Shorthand for category enables
  vid = cfg.video;
  mus = cfg.music;
  cli = cfg.clients;
  utl = cfg.utilities;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════════
    # VIDEO PLAYBACK
    # ═══════════════════════════════════════════════════════════════════════
    #
    # High-quality video playback for local and streaming content.
    # mpv for keyboard-driven workflows, VLC for graphical interaction.
    #

    # mpv - Minimalist, keyboard-driven video player
    # Scriptable, highly configurable, excellent codec support
    (lib.mkIf (vid.enable && vid.mpv) {
      environment.systemPackages = [ pkgs.mpv ];
    })

    # VLC - Swiss army knife of media players
    # Graphical UI, broad format support, streaming capabilities
    (lib.mkIf (vid.enable && vid.vlc) {
      environment.systemPackages = [ pkgs.vlc ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # MUSIC PLAYBACK
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Music playback and library organization.
    #
    # NOTE:
    # Onyx Digital Intelligence Development is actively building "Hadal",
    # an audiophile-grade music player and organization application.
    # Hadal is not yet available and is therefore not included here.
    #

    # Strawberry - Music player and library organizer
    # Fork of Clementine, supports multiple audio backends,
    # CD ripping, tag editing, and streaming services
    (lib.mkIf (mus.enable && mus.strawberry) {
      environment.systemPackages = [ pkgs.strawberry ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # MEDIA CLIENTS
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Clients for streaming from media servers.
    # These are CLIENT applications only - no servers or daemons.
    #

    # Jellyfin Media Player - Desktop client for Jellyfin servers
    # Native desktop application, NOT the Jellyfin server
    (lib.mkIf (cli.enable && cli.jellyfin) {
      environment.systemPackages = [ pkgs.jellyfin-media-player ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # UTILITIES
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Command-line tools for media acquisition, inspection, and conversion.
    # Overlap with Creator SIP is intentional and acceptable.
    #

    # yt-dlp - Video downloader
    # Download videos from YouTube and other sites
    (lib.mkIf (utl.enable && utl.ytdlp) {
      environment.systemPackages = [ pkgs.yt-dlp ];
    })

    # mediainfo - Media file inspector
    # Display technical information about audio/video files
    (lib.mkIf (utl.enable && utl.mediainfo) {
      environment.systemPackages = [ pkgs.mediainfo ];
    })

    # ffmpeg - Media conversion toolkit
    # Decode, encode, transcode, mux, demux, stream, filter
    # NOTE: Overlap with Creator SIP is intentional
    (lib.mkIf (utl.enable && utl.ffmpeg) {
      environment.systemPackages = [ pkgs.ffmpeg-full ];
    })
  ]);
}
