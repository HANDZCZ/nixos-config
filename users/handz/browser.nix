{ pkgs, user-info, ...}:

{
  home-manager.users.${user-info.name} = {
    home.sessionVariables = {
      BROWSER = "brave";
    };
    home.packages = with pkgs; [
      brave
    ];
  };
}
