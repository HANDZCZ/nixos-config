{ user-info, ...}:

{
  home-manager.users.${user-info.name} = {
    programs.btop = {
      enable = true;
      settings = {
        proc_sorting = "memory";
        proc_tree = true;
        proc_aggregate = true;
        proc_filter_kernel = true;
      };
    };
  };
}
