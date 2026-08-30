{ config, lib, networks, ... }:

let
  net-cfg = config.systemd.network;
  required-networks = lib.attrValues networks;
in {
  warnings = required-networks
    |> lib.filter (name: !net-cfg.netdevs ? "10-${name}")
    |> lib.map (name: "Network definition for '${name}' was not found in systemd.network.netdevs!");

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    networkmanager.enable = false;
  };

  systemd.network = {
    enable = true;

    links = {
      "10-phys0" = {
        matchConfig.PermanentMACAddress = "2a:6e:95:4e:27:54";
        linkConfig.Name = "phys0";
      };
    };

    # Virtual devices definitions
    netdevs = let
      mkVlan = name: id: mac: {
        "10-vlan-${name}" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan-${name}";
            MACAddress = mac;
          };
          vlanConfig.Id = id;
        };
      };
    in lib.mkMerge [
      # Bridge over physical interfaces
      {
        "10-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
          bridgeConfig.VLANFiltering = true;
        };
      }

      # Vlans
      (mkVlan "servers" 5 "02:e9:e8:4d:f8:d0")
      (mkVlan "lan" 10 "02:c1:6e:d3:ba:6a")
      (mkVlan "iot-net" 20 "02:56:ba:f5:17:d5")
    ];

    networks = let
      mkConfVlan = name: {
        "30-vlan-${name}" = {
          matchConfig.Name = "vlan-${name}";
          networkConfig.DHCP = "ipv4";
          dhcpV4Config = {
            UseDNS = false;
            UseRoutes = false;
            UseNTP = false;
          };
        };
      };
    in lib.mkMerge [
      # Device assignment
      # Add vlans and allow vlan ids for them in br0
      {
        "20-vlans" = rec {
          matchConfig.Name = "br0";
          vlan = [ "vlan-servers" "vlan-lan" "vlan-iot-net" ];
          bridgeVLANs = vlan
            |> lib.map (vname: {
                VLAN = net-cfg.netdevs."10-${vname}".vlanConfig.Id;
              });
          # br0 doesn't get or need any ip
          networkConfig.LinkLocalAddressing = false;
        };
      }
      # Add phys0 to br0
      {
        "20-phys0-br0" = {
          matchConfig.Name = "phys0";
          networkConfig.Bridge = "br0";
          # allow all vlans from bridge through this interface
          bridgeVLANs = net-cfg.networks."20-vlans".bridgeVLANs;
        };
      }

      # Configure devices
      {
        "30-vlan-servers" = {
          matchConfig.Name = "vlan-servers";
          networkConfig.DHCP = "ipv4";
        };
      }
      (mkConfVlan "lan")
      (mkConfVlan "iot-net")
    ];
  };
}
