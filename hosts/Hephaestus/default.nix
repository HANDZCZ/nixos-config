{ config, pkgs, lib, ... }:

let
  network-defs = {
    servers = {
      mac = "2a:69:d7:4a:e4:3e";
      vlan = 5;
      extraNetworksConfig = {
        routes = [{
          Gateway = "_dhcp4";
          Destination = "0.0.0.0/0";
          Table = "main";
          Metric = 512;
        }];
      };
    };
    lan = {
      mac = "2a:ae:d8:82:6c:dc";
      vlan = 10;
    };
    iot = {
      configure = false;
      mac = "2a:ec:cf:f4:5b:ed";
      vlan = 15;
    };
    iot-net = {
      configure = false;
      mac = "2a:ad:1a:2a:8c:0a";
      vlan = 20;
    };
  };
  networks = config.systemd.network.symm-net.networks
    |> lib.mapAttrs (name: cfg:
      {
        inherit name;
        inherit (cfg) vlan;
      }
      // (if cfg.configure
        then { inherit (cfg) interface; }
        else {})
    )
    |> lib.flip lib.recursiveUpdate (let
      microvm-cfg = config.systemd.network.symm-net.microvm;
    in
      if microvm-cfg.enable
      then microvm-cfg.networks
        |> lib.mapAttrs (_: val: { microvm = val; })
      else {}
    );
in {
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ../../modules/symmetric-networkd-dhcp-single-br.nix
    ../../modules/warn-open-ports.nix
    ./VM.nix
  ];

  _module.args = { inherit networks; };

  services.dell-fancontrol.enable = true;

  systemd.network.symm-net = {
    enable = true;
    microvm.enable = true;
    links = {
      phys0.permanentMac = "ec:f4:bb:f0:5d:f5";
    };
    networks = network-defs;
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.interfaces = {
    # 22 - ssh
    "${networks.servers.interface}" = {
      allowedTCPPorts = [ 22 ];
    };
    "${networks.lan.interface}" = {
      allowedTCPPorts = [ 22 ];
    };
  };

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
