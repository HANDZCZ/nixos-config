{ config, lib, pkgs, inputs, ... }:

let
  noctalia-package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell.package = lib.mkForce (noctalia-package.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ../../patches/noctalia/Fix-theme-template-apply-for-gtk.patch
      ../../patches/noctalia/Fix-theme-template-apply-for-niri.patch
      ../../patches/noctalia/Fix-theme-template-apply-for-alacritty.patch
    ];
  }));

  gtk =
    let
      settingsVersions = [ "3" "4" ];
      gtkConfigFn = version: {
        extraCss = ''
          @import url("${config.xdg.configHome}/gtk-${version}.0/noctalia.css");
        '';
      };
    in {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
    } // lib.genAttrs' settingsVersions (version: lib.nameValuePair "gtk${version}" (gtkConfigFn version));

  qt =
    let
      settingsVersions = [ "5" "6" ];
      qtConfigFn = version: {
        Appearance = {
          color_scheme_path = "${config.xdg.configHome}/qt${version}ct/colors/noctalia.conf";
          custom_palette = true;
        };
      };
    in {
      enable = true;
      platformTheme.name = "qtct";
      style.name = lib.mkForce null;
    } // lib.genAttrs' settingsVersions (version: lib.nameValuePair ("qt" + version + "ctSettings") (qtConfigFn version));

  programs.alacritty.settings =
    let
      alacritty = config.programs.alacritty;
    in {
      general.import = lib.mkIf (alacritty.enable && alacritty.settings != {}) [ "themes/noctalia.toml" ];
    };
}
