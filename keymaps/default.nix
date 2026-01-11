{ ... }:

{
  services.xserver.xkb.extraLayouts = {
    cz-winlike = {
      description = "Czech - WindowsLike";
      languages = [ "cze" ];
      symbolsFile = ./czech_winlike;
    };
  };
}

