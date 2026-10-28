{ config, networks, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;

    enabledCollectors = [];
    disabledCollectors = [];
  };

  services.prometheus.exporters.zfs = {
    enable = true;
  };

  networking.firewall.interfaces = {
    "${networks.servers.interface}" = {
      allowedTCPPorts = [
        config.services.prometheus.exporters.node.port
        config.services.prometheus.exporters.zfs.port
      ];
    };
  };
}
