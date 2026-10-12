{ config, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    openFirewall = true;

    settings = {
      server = {
        enable_gzip = true;
        http_addr = "0.0.0.0";
      };
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      prometheus
    ];

    provision = {
      enable = true;
      dashboards.settings.providers = [{
        name = "default";
        disableDeletion = false;
        options = {
          path = "/etc/grafana/dashboards";
          foldersFromFilesStructure = true;
        };
      }];
      datasources.settings = {
        prune = true;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
            editable = false;
          }
        ];
      };
    };
  };
}
