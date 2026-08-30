{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ./pihole.nix
    ./network.nix
  ];

  services.openssh.enable = true;

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
