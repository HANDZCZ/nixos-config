{ config, pkgs, lib, ... }:

let
  networks = lib.genAttrs [ "servers" "lan" "iot-net" ] (name: "vlan-${name}");
in {
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ../../modules/warn-open-ports.nix
    ./pihole.nix
    ./network.nix
    ./VM.nix
  ];

  _module.args = { inherit networks; };

  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  systemd.network.links."10-phys0" = {
    linkConfig.WakeOnLan = "magic";
  };

  networking.firewall.interfaces = {
    # 22 - ssh
    # 9 - Wake on lan
    "${networks.servers}" = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 9 ];
    };
    "${networks.lan}" = {
      allowedTCPPorts = [ 22 ];
    };
  };

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
