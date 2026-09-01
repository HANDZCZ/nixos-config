{ config, lib, networks, ... }:

let
  net-cfg = config.systemd.network;
  required-networks = lib.attrValues networks;

  vlan-offset = 15000;
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
      # Rename interface to phys0
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
      mkConfVlan = name: let
        vlan-id = net-cfg.netdevs."10-vlan-${name}".vlanConfig.Id;
        vlan-offset-id = vlan-id + vlan-offset;
      in {
        "30-vlan-${name}" = {
          matchConfig.Name = "vlan-${name}";
          networkConfig.DHCP = "ipv4";
          dhcpV4Config = {
            UseDNS = false;
            UseNTP = false;
          };
          # We need to handle cross subnet traffic
          # otherwise egress will want to go through default gateway and get blocked by rp_filter (from firewall)
          # so we will use PBR and isolate vlan routes to specific table
          # and turn it into symmetric routing
          dhcpV4Config = {
            RouteTable = vlan-offset-id;
            RouteMetric = 1024;
          };
          # Add vlan route to main table
          # so server-generated traffic can still be sent through the right vlan
          # and not through default gateway only
          routes = [{
            Gateway = "_dhcp4";
            Table = "main";
            Metric = 1024;
          }];
          # Add PBR rule to route traffic through vlan table
          # if it has vlan firewall mark
          routingPolicyRules = [
            {
              FirewallMark = vlan-offset-id;
              Table = vlan-offset-id;
            }
          ];
        };
      };
    in lib.mkMerge [
      # Configure br0
      {
        "20-br0" = rec {
          matchConfig.Name = "br0";
          # Add vlans and allow vlan ids for them
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
          bridgeVLANs = net-cfg.networks."20-br0".bridgeVLANs;
        };
      }

      # Configure vlans
      (mkConfVlan "servers")
      {
        "30-vlan-servers".routes = [{
          Gateway = "_dhcp4";
          Destination = "0.0.0.0/0";
          Table = "main";
          Metric = 512;
        }];
      }
      (mkConfVlan "lan")
      (mkConfVlan "iot-net")
    ];
  };

  networking.nftables = let
    # Marks incoming traffic with vlan specific mark if the traffic belongs to it and doesn't have a mark
    mkVlanMark = name:
      ''ct mark 0 iifname "vlan-${name}" ct mark set ${toString (net-cfg.netdevs."10-vlan-${name}".vlanConfig.Id + vlan-offset)}'';
  in {
    enable = true;
    # Add conntrack handling for vlan traffic
    tables.pbr_mangle = {
      family = "inet";
      content = ''
        chain prerouting {
          type filter hook prerouting priority mangle; policy accept;

          # Restore PBR mark from conntrack
          meta mark set ct mark

          # Mark previously unmarked connections according to ingress VLAN
          ${mkVlanMark "servers"}
          ${mkVlanMark "lan"}
          ${mkVlanMark "iot-net"}

          # Apply newly assigned connection mark to this packet
          meta mark set ct mark
        }

        chain output {
          type route hook output priority mangle; policy accept;

          # Apply PBR mark to locally generated packets
          meta mark set ct mark
        }
      '';
    };
  };
}
