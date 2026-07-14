{ inputs, pkgs, pkgs-unstable, ... }:

let
  nix-tools-steam-pkgs = inputs.nix-tools-steam.packages.${pkgs.stdenv.hostPlatform.system};
in {
  environment.systemPackages = with pkgs; [
    mangohud
    nix-tools-steam-pkgs.accela
    nix-tools-steam-pkgs.samrewritten
  ];

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [];
      platformOptimizations.enable = true;
      protontricks.enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = 1;
          LD_AUDIT = "${nix-tools-steam-pkgs.sls-steam}/lib/library-inject.so:${nix-tools-steam-pkgs.sls-steam}/lib/SLSsteam.so";
        };
      };
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
