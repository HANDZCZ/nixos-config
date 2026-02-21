{ config, pkgs, ... }:

let
  xdg = config.xdg;
in {
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" ];
    shellAliases = {
      # NixOS
      nix-rbs = "sudo nixos-rebuild switch --flake ${xdg.configHome}/nixos#nixos-desktop";
      nix-rbb = "sudo nixos-rebuild boot --flake ${xdg.configHome}/nixos#nixos-desktop";
      nix-lgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nix-sqr = "nix-store --query --roots";
      nix-sqref = "nix-store --query --referrers";

      # Remote launch
      # https://dblsaiko.net/kb-gui-login-ssh.html
      rlaunch-shell = ''systemd-run -S --uid="$(whoami)" -p PAMName=login -E XDG_SEAT=seat0 -E XDG_VTNR=1 -E XDG_SESSION_TYPE=tty -E XDG_SESSION_CLASS=user'';
      rlaunch-niri = ''systemd-run --uid="$(whoami)" -p PAMName=login -E XDG_SEAT=seat0 -E XDG_VTNR=1 -E XDG_SESSION_TYPE=tty -E XDG_SESSION_CLASS=user niri-session'';

      # Basic
      ll = "${pkgs.eza}/bin/eza -lag --icons -s type";
      cat = "${pkgs.bat}/bin/bat";
      lports = "${pkgs.iproute2}/bin/ss -lunt";

      # Docker
      #dc-stats = "docker container stats --no-stream";
      #ds-stats = "docker system df -v";

      # Git
      gspull = "${pkgs.git}/bin/git stash && git pull && git stash pop";
      glog = "${pkgs.git}/bin/git log --graph --show-signature --format=fuller";
      grcad = "${pkgs.git}/bin/git rebase -i --committer-date-is-author-date";

      # YT-dl
      ytdl_vid = "${pkgs.yt-dlp}/bin/yt-dlp --no-mark-watched --geo-bypass --no-playlist --cache-dir ${xdg.cacheHome}/youtube-dl --embed-thumbnail --add-metadata --merge-output-format mp4 -f \"bestvideo[height<=1080]+bestaudio[ext=m4a]\"";
      ytdl_au = "${pkgs.yt-dlp}/bin/yt-dlp --no-mark-watched --geo-bypass --no-playlist --cache-dir  ${xdg.cacheHome}/youtube-dl --embed-thumbnail --add-metadata -f \"bestaudio[ext=m4a]\"";
      ytdl_playlist_vid = "${pkgs.yt-dlp}/bin/yt-dlp --ignore-errors --no-mark-watched --geo-bypass --yes-playlist --cache-dir  ${xdg.cacheHome}/youtube-dl --embed-thumbnail --add-metadata --merge-output-format mp4 -f \"bestvideo[height<=1080]+bestaudio[ext=m4a]\" --output \"%(playlist_index)s. %(title)s.%(ext)s\"";
      ytdl_playlist_au = "${pkgs.yt-dlp}/bin/yt-dlp --ignore-errors --no-mark-watched --geo-bypass --yes-playlist --cache-dir  ${xdg.cacheHome}/youtube-dl --embed-thumbnail --add-metadata -f \"bestaudio[ext=m4a]\" --output \"%(playlist_index)s. %(title)s.%(ext)s\"";
    };
  };
}
