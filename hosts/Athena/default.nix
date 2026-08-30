{ config, pkgs, lib, ... }:

let
  networks = lib.genAttrs [ "servers" "lan" "iot-net" ] (name: "vlan-${name}");
in {
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ./pihole.nix
    ./network.nix
    ./VM.nix
  ];

  _module.args = { inherit networks; };

  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.interfaces = {
    "${networks.servers}" = {
      allowedTCPPorts = [ 22 ];
    };
    "${networks.lan}" = {
      allowedTCPPorts = [ 22 ];
    };
  };

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
