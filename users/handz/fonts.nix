{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    dejavu_fonts
  ];

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
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
      };
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "DejaVu Sans";
      size = 10;
    };
  };

  qt = {
    enable = true;
    qt6ctSettings = {
      Fonts = {
        fixed = "\"JetBrainsMono Nerd Font,10\"";
        general = "\"DejaVu Sans,10\"";
      };
    };
  };
}
