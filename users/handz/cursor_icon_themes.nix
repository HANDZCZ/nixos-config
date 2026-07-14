{ lib, pkgs, user-info, ... }:

let
  cursor_theme = {
    name = "Qogir";
    package = pkgs.qogir-icon-theme;
    size = 24;
  };
  icon_theme = {
    name = "Qogir";
    package = pkgs.qogir-icon-theme;
  };
in {
  home-manager.users.${user-info.name} = {
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      name = cursor_theme.name;
      size = cursor_theme.size;
      package = cursor_theme.package;
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = icon_theme.name;
        package = icon_theme.package;
      };
    };

    qt =
      let
        settingsVersions = [ "5" "6" ];
        qtConfigFn = version: {
          Appearance = {
            icon_theme = icon_theme.name;
          };
        };
      in {
        enable = true;
        platformTheme.name = "qtct";
      } // lib.genAttrs' settingsVersions (version: lib.nameValuePair ("qt" + version + "ctSettings") (qtConfigFn version));
  };
}
