{ config, networks, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;

    enabledCollectors = [];
    disabledCollectors = [];
  };

  networking.firewall.interfaces = {
    "${networks.servers.interface}" = {
      allowedTCPPorts = [
        config.services.prometheus.exporters.node.port
      ];
    };
  };
}
