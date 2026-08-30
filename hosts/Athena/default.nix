{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ./pihole.nix
    ./network.nix
  ];

  services.openssh.enable = true;

  warnings = let
    fw-cfg = config.networking.firewall;
    mkPortWarn = proto: port: "${proto} ${toString port} is allowed on all interfaces!";
  in lib.map (port: mkPortWarn "TCP" port) fw-cfg.allowedTCPPorts
    ++ lib.map (port: mkPortWarn "TCP" port) fw-cfg.allowedTCPPortRanges
    ++ lib.map (port: mkPortWarn "UDP" port) fw-cfg.allowedUDPPorts
    ++ lib.map (port: mkPortWarn "UDP" port) fw-cfg.allowedUDPPortRanges;

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
