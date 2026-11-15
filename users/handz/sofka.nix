{ user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    programs.sofka = {
      enable = true;
    };
  };
}
