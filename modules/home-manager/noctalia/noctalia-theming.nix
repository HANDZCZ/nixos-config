{ config, lib, pkgs, ... }:

let
  cfg = config.programs.noctalia-shell;
in {
  options.programs.noctalia-shell = {
    enableTheming = lib.mkEnableOption "theming through noctalia" // {
      default =
        lib.attrByPath [ "templates" "activeTemplates" ] [] cfg.settings
        |> lib.any (template: template.enabled);
    };
  };

  config = lib.mkIf cfg.enableTheming {
    programs.noctalia-shell.overlays = [
      (_: prev: prev.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../../../patches/noctalia/Fix-theme-template-apply-for-gtk.patch
          ../../../patches/noctalia/Fix-theme-template-apply-for-niri.patch
          ../../../patches/noctalia/Fix-theme-template-apply-for-alacritty.patch
        ];
      }))
    ];

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
  };
}
