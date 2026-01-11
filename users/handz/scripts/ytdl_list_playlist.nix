{ pkgs, config, ... }:

pkgs.writeShellScriptBin "ytdl_list_playlist" ''
  ${pkgs.yt-dlp}/bin/yt-dlp --ignore-errors --no-mark-watched --flat-playlist --geo-bypass --yes-playlist --cache-dir ${config.xdg.cacheHome}/youtube-dl --get-title --get-duration $@ | ${pkgs.gnused}/bin/sed -r 'N;s/(.*)\n(.*)/\2 - \1/'
''
