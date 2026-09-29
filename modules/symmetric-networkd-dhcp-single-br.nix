{ config, lib, ... }:

let
  net-cfg = config.systemd.network;

  isVlan = net: net.vlan != null;
  shouldConfigure = net: net.configure;

  links = net-cfg.symm-net.links
    |> lib.mapAttrsToList (key: val: val // { name = key; });
  networks = net-cfg.symm-net.networks
    |> lib.mapAttrsToList (key: val: val // { name = key; });
  required-networks = networks
    |> lib.filter shouldConfigure;

  vlan-offset = 15000;
in {
  options.systemd.network.symm-net = {
    enable = lib.mkEnableOption "symmetric routing definition with a single bridge";
    microvm = lib.mkOption {
      description = "Microvm configuration for networking.";
      type = lib.types.submodule { options = {
        enable = lib.mkEnableOption ''adding Microvm taps "vm-<network.<name>>-*" to bridge with correct vlan'';
        networks = lib.mkOption {
          readOnly = true;
          description = "Provides ids used in microvm.interface.id for defined vlan networks on the bridge.";
          default = net-cfg.symm-net.networks
            |> lib.mapAttrs (net-name: _: {
              mkId = vm-name: "vm-${net-name}-${vm-name}";
            });
          type = lib.types.attrsOf (lib.types.submodule { options = {
            mkId = lib.mkOption {
              type = lib.types.functionTo lib.types.str;
              description = ''
                Generated id when provided with microvm name.
                Resulting id has format "vm-<network-name>-<microvm-name>".
              '';
            };
          };});
        };
      };};
    };
    links = lib.mkOption {
      description = "Links that should be configured and added to bridge.";
      default = [];
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          permanentMac = lib.mkOption {
            type = lib.types.str;
            description = ''
              Mac of the interface to add to bridge.
              If specified link interface with this mac will be renamed.
            '';
          };
          vlans = lib.mkOption {
            type = lib.types.listOf lib.types.ints.unsigned;
            default = [];
            description = ''
              Vlans that this interface can carry.
              If left empty all vlans on bridge will be allowed through this link.
            '';
          };
        };
      });
    };
    networks = lib.mkOption {
      description = "Networks that should be configured.";
      default = [];
      type = lib.types.attrsOf (lib.types.submodule ({ name, config, ...}: {
        options = {
          configure = lib.mkEnableOption "create and configure interface for this network" // {
            default = true;
          };
          interface = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = ''
              Name of the interface for network.
              If unspecified name is used and when vlan is specified "vlan-<name>" is used.
            '';
          };
          vlan = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.unsigned;
            default = null;
            description = ''
              Vlan id for network.
              If unspecified network is not a vlan.
            '';
          };
          mac = lib.mkOption {
            type = lib.types.str;
            description = ''
              Mac for the inteface.
              If unspecified interface will not be configured or created.
            '';
          };
          extraNetdevConfig = lib.mkOption {
            type = lib.types.attrs;
            description = "Extra config to add to systemd.network.netdevs for this network.";
          };
          extraNetworksConfig = lib.mkOption {
            type = lib.types.attrs;
            description = "Extra config to add to systemd.network.networks for this network.";
          };
        };
        config = {
          interface = lib.mkDefault (if config.vlan != null then "vlan-${name}" else name);
        };
      }));
    };
  };

  config = lib.mkIf net-cfg.symm-net.enable {
    warnings = required-networks
      |> lib.filter (net: !net-cfg.netdevs ? "10-${net.interface}")
      |> lib.map (net: "Network definition for '${net.interface}' was not found in systemd.network.netdevs!");

    networking = {
      useDHCP = false;
      dhcpcd.enable = false;
      networkmanager.enable = false;
      # Enforce symmetric routing by checking if packet goes out the same interface it came in
      firewall.checkReversePath = "strict";
    };

    systemd.network = {
      enable = true;

      # Rename interfaces
      links = links
        |> lib.filter (link: link.permanentMac != null)
        |> lib.flip lib.genAttrs' (link: lib.nameValuePair "10-${link.name}" {
          matchConfig.PermanentMACAddress = link.permanentMac;
          linkConfig.Name = link.name;
        });

      # Virtual device definitions
      netdevs = let
        mkVlan = net: {
          "10-${net.interface}" = {
            netdevConfig = {
              Kind = "vlan";
              Name = net.interface;
              MACAddress = net.mac;
            };
            vlanConfig.Id = net.vlan;
          };
        };
      in lib.mkMerge <| lib.flatten <| [
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
        (required-networks
          |> lib.filter isVlan
          |> lib.map mkVlan
        )
        # Extra configs
        (required-networks
          |> lib.map (net: {
            "10-${net.interface}" = net.extraNetdevConfig;
          })
        )
      ];

      networks = let
        mkConfVlan = net: let
          vlan-offset-id = net.vlan + vlan-offset;
        in {
          "30-${net.interface}" = {
            matchConfig.Name = net.interface;
            networkConfig.DHCP = "ipv4";
            dhcpV4Config = {
              UseDNS = false;
              UseNTP = false;
            };
            # We need to handle cross-subnet traffic
            # otherwise egress will want to go through default gateway and get blocked by rp_filter (from firewall)
            # so we will use PBR and isolate vlan routes to a specific table
            # and turn it into symmetric routing
            dhcpV4Config = {
              RouteTable = vlan-offset-id;
              RouteMetric = 1024;
            };
            # Add vlan route to main table
            # so server-generated traffic can still be sent through the right vlan
            # and not through the default gateway only
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
        mkMicrovmConf = net: {
          "40-microvm-${net.name}" = {
            matchConfig.Name = "vm-${net.name}-*";
            networkConfig.Bridge = "br0";
            bridgeVLANs = [{
              PVID = net.vlan;
              EgressUntagged = net.vlan;
            }];
          };
        };
        br0-vlans = networks
          |> lib.filter isVlan;
      in lib.mkMerge <| lib.flatten <| [
        # Configure br0
        {
          "20-br0" = {
            matchConfig.Name = "br0";
            # Add vlans and allow vlan ids for them
            vlan = br0-vlans
              |> lib.filter shouldConfigure
              |> lib.map (net: net.interface);
            bridgeVLANs = br0-vlans |> lib.map (net: { VLAN = net.vlan; });
            # br0 doesn't get or need any ip
            networkConfig.LinkLocalAddressing = false;
          };
        }
        (links |> lib.map (link: {
          "20-${link.name}-br0" = {
            matchConfig.Name = link.name;
            networkConfig.Bridge = "br0";
            bridgeVLANs = if link.vlans == []
              then net-cfg.networks."20-br0".bridgeVLANs
              else link.vlans |> lib.map (vlan: { VLAN = vlan; });
          };
        }))
        # Add Microvm taps to br0
        (if net-cfg.symm-net.microvm.enable
          then (br0-vlans |> lib.map mkMicrovmConf)
          else {}
        )

        # Configure vlans
        (required-networks
          |> lib.filter isVlan
          |> lib.map mkConfVlan
        )

        # Extra configs
        (required-networks
          |> lib.map (net: {
            "30-${net.interface}" = net.extraNetworksConfig // {
              matchConfig.Name = net.interface;
            };
          })
        )
      ];
    };

    networking.nftables = let
      # Marks incoming traffic with a vlan specific mark if the traffic belongs to it and doesn't have a mark
      mkVlanMark = net:
        ''ct mark 0 iifname "${net.interface}" ct mark set ${toString (net.vlan + vlan-offset)}'';
      marks = required-networks
        |> lib.filter isVlan
        |> lib.map mkVlanMark
        |> lib.concatLines;
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
            ${marks}

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
  };
}
