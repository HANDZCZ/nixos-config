{ pkgs, ... }:

{
  imports = [
    ./bash.nix
  ];

  home.username = "handz";
  home.homeDirectory = "/home/handz";
  home.stateVersion = "25.11";
}
