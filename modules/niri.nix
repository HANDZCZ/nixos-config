{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    alacritty
    wev
  ];

  programs.niri.enable = true;
  services.playerctld.enable = true;
}
