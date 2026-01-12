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

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = lib.mkForce null;
    qt6ctSettings = {
      Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf";
	custom_palette = true;
        style = "Fusion";
        standar_dialogs = "default";
      };
    };
  };

  programs.alacritty.settings.general.import = lib.mkIf config.programs.alacritty.enable [ "themes/noctalia.toml" ];
}
