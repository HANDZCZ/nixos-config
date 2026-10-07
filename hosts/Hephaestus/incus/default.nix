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

  mkShares = {
    vm-name,
    shares,
  }: let
    basePath = "/var/lib/incus-shares/${vm-name}";
    getSource = name: cfg: if cfg ? source then cfg.source else "${basePath}/${name}";
  in {
    incusCommands = shares
      |> lib.mapAttrsToList (name: cfg: /* bash */ ''
        incus config device add ${vm-name} ${name} disk source=${getSource name cfg} path=${cfg.mountPoint} || true
      '')
      |> lib.concatLines;
    hostImport = {
      systemd.tmpfiles.settings."20-incus-shares-${vm-name}" = shares |> lib.mapAttrs' (name: cfg:
        lib.nameValuePair (getSource name cfg) { d.mode = ":0775"; }
      );
    };
  };

  vms = builtins.readDir ./.
    |> lib.flip removeAttrs [ "default.nix" ]
    |> lib.mapAttrsToList (name: value: import ./${name} {
      vm-name = name |> lib.removeSuffix ".nix";
      inherit mkNet mkShares;
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
