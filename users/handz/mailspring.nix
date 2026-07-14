{ user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    imports = [
      ../../modules/home-manager/mailspring.nix
    ];

    programs.mailspring = {
      enable = true;
      # window doesn't get created under wayland
      # and no useful logs are produced...
      forceX11 = true;
    };
  };
}
