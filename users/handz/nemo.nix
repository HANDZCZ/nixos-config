{ pkgs, user-info, ... }:

{
  home-manager.users.${user-info.name}.home.packages = with pkgs; [
    # file browser
    (nemo-with-extensions.override {
      extensions = with pkgs; [
        nemo-mediainfo-tab
      ];
    })
    file-roller
  ];
  services.gvfs.enable = true;
}
