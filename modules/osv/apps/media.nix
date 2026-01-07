# OSV Media SIP
#
# Media consumption tools. Does NOT configure audio/GPU stacks or run servers.
# Excludes: Kodi, cmus, Jellyfin server, *arr suite, automation daemons.
# Hadal (audiophile music player) is in development and not yet included.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.media;
  vid = cfg.video;
  mus = cfg.music;
  cli = cfg.clients;
  utl = cfg.utilities;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Video
    (lib.mkIf (vid.enable && vid.mpv) {
      environment.systemPackages = [ pkgs.mpv ];
    })
    (lib.mkIf (vid.enable && vid.vlc) {
      environment.systemPackages = [ pkgs.vlc ];
    })

    # Music
    (lib.mkIf (mus.enable && mus.strawberry) {
      environment.systemPackages = [ pkgs.strawberry ];
    })

    # Clients (no servers)
    (lib.mkIf (cli.enable && cli.jellyfin) {
      environment.systemPackages = [ pkgs.jellyfin-media-player ];
    })

    # Utilities
    (lib.mkIf (utl.enable && utl.ytdlp) {
      environment.systemPackages = [ pkgs.yt-dlp ];
    })
    (lib.mkIf (utl.enable && utl.mediainfo) {
      environment.systemPackages = [ pkgs.mediainfo ];
    })
    (lib.mkIf (utl.enable && utl.ffmpeg) {
      environment.systemPackages = [ pkgs.ffmpeg-full ];
    })
  ]);
}
