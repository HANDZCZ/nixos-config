{ pkgs, inputs, ... }:

let
  niri-nix-pkgs = inputs.niri-nix.packages.${pkgs.stdenv.hostPlatform.system};
in {
  environment.systemPackages = with pkgs; [
    niri-nix-pkgs.xwayland-satellite-unstable
    alacritty
    wev
  ];

  programs.niri.enable = true;
  services.playerctld.enable = true;
}
