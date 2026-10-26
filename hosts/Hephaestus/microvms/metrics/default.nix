{ vm-name, mkMicrovmConfig, mkNet, root-conf, prometheus-cfg, ... }:
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
          mac = "2a:d3:4a:cb:b4:e0";
        })
      ];
      config = { ... }: {
        imports = [
          ./prometheus-daemon.nix
          ./grafana.nix
        ];

        services.prometheus = {
          # Add scrape configs for other services
          inherit (prometheus-cfg) scrapeConfigs;
        };

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedOptimisation = true;
        };

        networking.firewall.allowedTCPPorts = [ 80 ];

        microvm = {
          vcpu = 4;
          mem = 4096;
          volumes = [
            rec {
              label = "metrics-data";
              image = "${label}.img";
              mountPoint = "/var/lib";
              size = 32 * 1024;
              direct = true;
            }
          ];
        };
      };
    };
  };
}
