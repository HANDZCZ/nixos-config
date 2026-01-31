{ inputs, pkgs, pkgs-unstable, ... }:

{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];

  environment.systemPackages = with pkgs; [
    mangohud
  ];

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [];
      platformOptimizations.enable = true;
      protontricks.enable = true;
    };
    gamescope = {
      enable = true;
      # gamescope in steam gives error:
      # failed to inherit capabilities: Operation not permitted
      # workaroud is to use ananicy
      capSysNice = false;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
  services.ananicy = {
    enable = true;
    package = pkgs-unstable.ananicy-cpp;
    rulesProvider = pkgs-unstable.ananicy-rules-cachyos;
  };
}
