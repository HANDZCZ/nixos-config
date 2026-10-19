{ lib }:

rec {
  local-domain = "ce.handz.eu.org";

  dns = {
    primary = {
      inherit (services.technitium) domains ip;
    };
  };

  services = {
    technitium = {
      ip = "192.168.5.5";
      domains = [
        "technitium.${local-domain}"
      ];
    };
    paperless.domains = [
      "paperless.${local-domain}"
    ];
    prometheus.domains = [
      "prometheus.${local-domain}"
    ];
    grafana.domains = [
      "grafana.${local-domain}"
    ];
  };

  hosts = {
    Hephaestus = {
      domains = [
        "hephaestus.${local-domain}"
      ];
    };
  };

  vms = {
    inherit (services)
      technitium
      paperless;
    metrics = with services; {
      domains = [
        "metrics.${local-domain}"
      ]
        ++ prometheus.domains
        ++ grafana.domains;
    };
  };
}
