{ lib, pkgs, ... }:

let
  fonts = {
    serif = [
      "DejaVu Serif"
    ];
    sansSerif = [
      "DejaVu Sans"
    ];
    monospace = [
      "JetBrainsMono Nerd Font"
    ];
    emoji = [
      "Noto Color Emoji"
    ];
    size = 10;
  };
in {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    dejavu_fonts
  ];

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = fonts.serif;
        sansSerif = fonts.sansSerif;
        monospace = fonts.monospace;
        emoji = fonts.emoji;
      };
    };
  };

  gtk = {
    enable = true;
    font = {
      name = builtins.elemAt fonts.sansSerif 0;
      size = fonts.size;
    };
  };

  qt =
    let
      settings = [ "qt6ctSettings" "qt5ctSettings" ];
      qtConfig = {
        Fonts = {
          fixed = "\"${builtins.elemAt fonts.monospace 0},${builtins.toString fonts.size}\"";
          general = "\"${builtins.elemAt fonts.sansSerif 0},${builtins.toString fonts.size}\"";
        };
      };
    in {
      enable = true;
    } // lib.genAttrs settings (_: qtConfig);
}
