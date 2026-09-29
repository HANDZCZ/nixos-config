{ config, networks, lib, ... }:

let
  net-cfg = config.systemd.network;
in {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 16384; # MiB
      cores = 12;
    };

    virtualisation.qemu.networkingOptions = let
        mkEth = num: mac: [
          "-device virtio-net-pci,netdev=net${toString num},mac=${mac}"
          "-netdev bridge,id=net${toString num},br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper"
        ];
    in lib.mkForce <| lib.flatten <| lib.imap1 (idx: mac: mkEth idx mac) <| [
      "52:54:00:12:35:57"
      "52:54:00:12:35:58"
      "52:54:00:12:35:59"
      "52:54:00:12:35:60"
    ];

    systemd.network = {
      networks = let
        mkBrLink = vname: mac: let
          vlan = networks.${vname}.vlan;
        in {
          "20-ethX-vlan${toString vlan}-br0" = {
            matchConfig.MACAddress = mac;
            networkConfig.Bridge = "br0";
            bridgeVLANs = [{
              PVID = vlan;
              EgressUntagged = vlan;
            }];
          };
        };
      in lib.mkMerge [
        (mkBrLink "servers" "52:54:00:12:35:57")
        (mkBrLink "lan" "52:54:00:12:35:58")
        (mkBrLink "iot-net" "52:54:00:12:35:59")
        (mkBrLink "iot" "52:54:00:12:35:60")
      ];
    };
  };
}
