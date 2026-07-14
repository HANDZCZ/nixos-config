{ pkgs, ... }:

let
  user = "handz";
in {
  imports = [
    ../../modules/niri.nix
    ../../modules/steam.nix
    ../../modules/sunshine.nix
  ];

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "secure_tm";
    extraGroups = [ "wheel" "networkmanager" "gamemode" ];
    packages = with pkgs; [];
  };

  home-manager.users.${user} = {
    imports = [ ./home.nix ];

    home.username = "${user}";
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "25.11";
  };

  programs = {
    # needed to open ports
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
    sniffnet.enable = true;
  };
  services.gvfs.enable = true;
  services.zerotierone.enable = true;

}
