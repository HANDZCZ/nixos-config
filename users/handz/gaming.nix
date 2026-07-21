{ pkgs, pkgs-unstable, user-info, ... }:

{
  imports = [
    ../../modules/steam.nix
    ../../modules/hv-bypass.nix
  ];

  home-manager.users.${user-info.name} = {
    home.packages = with pkgs; [
      ludusavi
      lutris
      heroic
      pkgs-unstable.protonplus

      # utils for winetricks
      unrar
      unzip
      cabextract
      p7zip
    ];
  };
}
