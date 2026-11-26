{ user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        dialect = "uk";
        update_check = false;
        enter_accept = true;
        style = "full";
        #threads.enabled = true;
      };
      daemon.enable = true;
    };
  };
}
