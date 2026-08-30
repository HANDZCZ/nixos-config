{ config, lib, ... }:

let
  net-cfg = config.systemd.network;
in {
  virtualisation.vmVariant = {
    virtualisation.qemu.networkingOptions = lib.mkForce [
      "-device virtio-net-pci,netdev=net1,mac=52:54:00:12:34:57"
      "-netdev bridge,id=net1,br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper"

      "-device virtio-net-pci,netdev=net2,mac=52:54:00:12:34:58"
      "-netdev bridge,id=net2,br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper"

      "-device virtio-net-pci,netdev=net3,mac=52:54:00:12:34:59"
      "-netdev bridge,id=net3,br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper"
    ];

    systemd.network = {
      networks = let
        mkBrLink = vname: mac: let
          vlan = net-cfg.netdevs."10-vlan-${vname}".vlanConfig.Id;
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
        (mkBrLink "servers" "52:54:00:12:34:57")
        (mkBrLink "lan" "52:54:00:12:34:58")
        (mkBrLink "iot-net" "52:54:00:12:34:59")
      ];
    };
  };
}
