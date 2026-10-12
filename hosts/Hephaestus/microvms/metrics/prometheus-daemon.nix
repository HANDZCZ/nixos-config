{ config, ... }:

{
  services.prometheus = {
    enable = true;
    enableReload = true;
    retentionTime = "30d";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.port}" ]; }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.port
  ];
}
