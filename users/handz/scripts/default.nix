{ pkgs, hm-config, user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    home.packages = [
      (pkgs.callPackage ./ytdl_list_playlist.nix {
        cacheHome = hm-config.xdg.cacheHome;
      })
      (pkgs.callPackage ./fd-list.nix {})
    ];
  };
}
