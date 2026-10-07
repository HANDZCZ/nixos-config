{ vm-name, mkMicrovmConfig, mkNet, root-conf, ... }:
{ config, lib, networks, ... }:

let
  vmDir = config.microvm.stateDir + "/${vm-name}";
in {
  microvm.vms.${vm-name} = {
    autostart = true;
    restartIfChanged = true;
    config = mkMicrovmConfig {
      host-info = {
        hostName = vm-name;
        inherit vm-name;
      };
      root = root-conf;
      networks = lib.foldl' lib.recursiveUpdate {} [
        (mkNet {
          net = networks.servers;
          mac = "2a:2f:b5:f6:ff:2d";
        })
      ];
      config = { config, ... }: {
        imports = [
          ../../../modules/paperless.nix
        ];

        services.paperless.port = 80;
        # Allow hydra to bind port 80
        systemd.services.paperless-web.serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          PrivateUsers = lib.mkForce false;
        };

        networking.firewall.allowedTCPPorts = [
          config.services.paperless.port
        ];

        microvm = {
          vcpu = 4;
          mem = 4096;
          volumes = [
            rec {
              label = "postgresql-data";
              image = "${label}.img";
              mountPoint = "/var/lib/postgresql";
              size = 16 * 1024;
              direct = true;
            }
          ];
          shares = [
            rec {
              proto = "virtiofs";
              tag = "paperless-data";
              source = "${vmDir}/${tag}";
              mountPoint = config.services.paperless.dataDir;
            }
          ];
        };
      };
    };
  };
}
