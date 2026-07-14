{ pkgs, user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    services.podman = {
      enable = true;
    };

    home.packages = with pkgs; [
      podman-compose
      podman-desktop
    ];
  };
}
