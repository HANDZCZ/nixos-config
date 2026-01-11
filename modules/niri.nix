{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    alacritty
    swayidle
    wev
  ];

  programs.niri.enable = true;
  services.playerctld.enable = true;
}
