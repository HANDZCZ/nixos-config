{ lib, ... }:

let
  mkNet = {
    vm-name,
    net,
    mac,
    prefix ? "br-",
    posfix ? ""
  }: let
    nicName = "${prefix}${net.name}${posfix}";
  in /* bash */ ''
    incus config device add ${vm-name} ${nicName} nic \
      nictype=bridged parent=br0 vlan=${toString net.vlan} hwaddr=${mac} name=${nicName} || true
  '';

  vms = builtins.readDir ./.
    |> lib.flip removeAttrs [ "default.nix" ]
    |> lib.mapAttrsToList (name: value: import ./${name} {
      vm-name = name |> lib.removeSuffix ".nix";
      inherit mkNet;
    });
in {
  imports = [
    ../../../modules/incus-instances.nix
  ] ++ vms;

  # Don't intercept br0 vlan filtered bridge!
  # When left on default (both =1) this completely breaks return traffic
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
  };
  networking.nftables.enable = true;
  virtualisation.incus = {
   enable = true;
   preseed = {
      networks = [];
      profiles = [
        {
          name = "default";
          devices = {
            root = {
              path = "/";
              pool = "default";
              size = "50GiB";
              type = "disk";
            };
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
        }
      ];
    };
  };
}
