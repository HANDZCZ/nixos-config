{ pkgs, user-info, ... }:

{
  home-manager.users.${user-info.name}.xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; lib.mkForce [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" "gnome" ];
      };
    };
  };
}
