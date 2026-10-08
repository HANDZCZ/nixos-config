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
          mac = "2a:c1:3c:6e:ee:15";
        })
      ];
      config = { ... }: {
        imports = [
          ../../../modules/dnscrypt-proxy.nix
        ];

        services.resolved.enable = false;
        networking.nameservers = [ "127.0.0.1" ];

        services.dnscrypt-proxy = {
          listenOn = [ "127.0.0.1:1053" ];
          ipv6Support = false;
          useCache = false; # handled by technitium
          webui = {
            enable = true;
            openFirewall = true;
          };
        };

        services.technitium-dns-server = {
          enable = true;
          openFirewall = true;
          firewallTCPPorts = [ 53 80 ];
          firewallUDPPorts = [ 53 ];
        };

        systemd.services.technitium-dns-server.environment = {
          DNS_SERVER_WEB_SERVICE_HTTP_PORT = "80";
          DNS_SERVER_FORWARDERS = "127.0.0.1:1053";
          DNS_SERVER_FORWARDER_PROTOCOL = "udp";
          DNS_SERVER_LOG_USING_LOCAL_TIME = "false";
        };

        microvm = {
          vcpu = 2;
          mem = 2048;
          volumes = [
            rec {
              label = "technitium-data";
              image = "${label}.img";
              mountPoint = "/var/lib/private/technitium-dns-server";
              size = 5 * 1024;
              direct = true;
            }
          ];
        };
      };
    };
  };
}
