{ user-info, ... }:

{
  imports = [
    ../../../modules/niri.nix
  ];

  home-manager.users.${user-info.name} = {
    imports = [
      ./input.nix
      ./outputs.nix
      ./layout.nix
      ./keybinds.nix
      ./window_rules.nix
      ./noctalia.nix
    ];

    wayland.windowManager.niri = {
      enable = true;
      package = null;
      validation.enable = false;

      settings = {
        prefer-no-csd = {};
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        clipboard.disable-primary = {};
        gestures.hot-corners.off = {};
      };
    };
  };
}
