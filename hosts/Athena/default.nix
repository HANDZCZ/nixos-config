{ config, pkgs, lib, ... }:

let
  network-defs = {
    servers = {
      mac = "02:e9:e8:4d:f8:d0";
      vlan = 5;
      extraNetworksConfig = {
        routes = [{
          Gateway = "_dhcp4";
          Destination = "0.0.0.0/0";
          Table = "main";
          Metric = 512;
        }];
        dhcpV4Config = {
          UseDNS = lib.mkForce true;
          UseNTP = lib.mkForce true;
        };
      };
    };
    lan = {
      mac = "02:c1:6e:d3:ba:6a";
      vlan = 10;
    };
    iot-net = {
      mac = "02:56:ba:f5:17:d5";
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
    ../../modules/warn-open-ports.nix
    ../../modules/symmetric-networkd-dhcp-single-br.nix
    ./pihole.nix
    ./VM.nix
  ];

  _module.args = { inherit networks; };

  systemd.network.symm-net = {
    enable = true;
    microvm.enable = true;
    links = {
      phys0.permanentMac = "2a:6e:95:4e:27:54";
    };
    networks = network-defs;
  };

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
