{ config, lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3
    nwg-look
    kdePackages.qt6ct
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      # disable GTK4 writing gtk.css
      package = null;
    };
  };

  qt =
    let
      settingsVersions = [ "5" "6" ];
      qtConfigFn = version: {
        Appearance = {
          color_scheme_path = "${config.home.homeDirectory}/.config/qt${version}ct/colors/noctalia.conf";
          custom_palette = true;
        };
      };
    in {
      enable = true;
      platformTheme.name = "qtct";
      style.name = lib.mkForce null;
    } // lib.genAttrs' settingsVersions (version: lib.nameValuePair ("qt" + version + "ctSettings") (qtConfigFn version));

  programs.alacritty.settings.general.import = lib.mkIf config.programs.alacritty.enable [ "themes/noctalia.toml" ];
}
