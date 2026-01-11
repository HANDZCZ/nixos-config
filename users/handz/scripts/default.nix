{ pkgs, config, ... }:

{
  home.packages = [
    (import ./ytdl_list_playlist.nix { inherit config pkgs; })
  ];
}
