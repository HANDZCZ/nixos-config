{ config, pkgs, lib, ... }:

let
  network-defs = {
    servers = {
      mac = "2a:69:d7:4a:e4:3e";
      vlan = 5;
    };
    lan = {
      mac = "2a:ae:d8:82:6c:dc";
      vlan = 10;
      # FIXME: once servers net is up use that
      extraNetworksConfig = {
        routes = [{
          Gateway = "_dhcp4";
          Destination = "0.0.0.0/0";
          Table = "main";
          Metric = 512;
        }];
      };
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
    );
in {
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/zramSwap.nix
    ../../modules/symmetric-networkd-dhcp-single-br.nix
    ./VM.nix
  ];

  _module.args = { inherit networks; };

  systemd.network = {
    symm-net = {
      enable = true;
      microvm.enable = true;
      links = {
        phys0.permanentMac = "ec:f4:bb:f0:5d:f5";
      };
      networks = network-defs;
    };
    links."10-phys-bak" = {
      matchConfig.PermanentMACAddress = "ec:f4:bb:f0:5d:f4";
      linkConfig.Name = "phys-bak";
    };
    netdevs."10-br0" = {
      bridgeConfig.STP = true;
    };
    networks."20-phys-bak-br0" = {
      matchConfig.Name = "phys-bak";
      networkConfig.Bridge = "br0";
      bridgeVLANs = [{
        PVID = networks.servers.vlan;
        EgressUntagged = networks.servers.vlan;
      }];
    };
  };

  services.openssh = {
    enable = true;
  };

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
