{ lib, hm-config, user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    xresources.properties = {
      "xterm*internalBorder" = 5;
      "xterm*cursorBlink" = false;
      "xterm*faceName" = lib.head hm-config.fonts.fontconfig.defaultFonts.monospace;
      "xterm*faceSize" = 12;
      "xterm*background" = "black";
      "xterm*foreground" = "white";
    };
  };
}
