{ lib, pkgs, ... }:

let
  package = pkgs.qimgv.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (pkgs.fetchpatch2 {
        name = "Fix-system-theme-usage.diff";
        url = "https://github.com/easymodo/qimgv/pull/639.diff?full_index=1";
        hash = "sha256-Vvd7hjBs5YZ9uILtvs3CTkh9I823pMyMWNuVOe5u8d0=";
      })
    ];
  });
in {
  home.packages = [ package ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "image/png"
    "image/jpeg"
    "image/webp"
    "image/gif"
    "image/bmp"
  ]  (_: "qimgv.desktop");

  xdg.configFile."qimgv/qimgv.conf" = {
    text = lib.generators.toINI {} {
      General = {
        JPEGSaveQuality = 100;
        infoBarWindowed = true;
        playVideoSounds = true;
        zoomIndicatorMode = 1;
        useSystemColorScheme = true;
      };
    };
  };
}
