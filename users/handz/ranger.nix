{ ... }:

{
  programs.ranger = {
    enable = true;
    settings = {
      show_hidden = true;
    };
    extraConfig = ''
      default_linemode devicons
    '';
    plugins = [
      {
        name = "ranger_devicons";
        src = builtins.fetchGit {
          url = "https://github.com/alexanderjeurissen/ranger_devicons.git";
          rev = "1bcaff0366a9d345313dc5af14002cfdcddabb82";
        };
      }
    ];
  };
}
