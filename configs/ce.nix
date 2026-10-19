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
        "dns.${local-domain}"
        "technitium.lan"
        "dns-server.lan"
      ];
    };
    paperless.domains = [
      "paperless.${local-domain}"
      "paperless.lan"
    ];
    prometheus.domains = [
      "prometheus.${local-domain}"
      "prometheus.lan"
    ];
    grafana.domains = [
      "grafana.${local-domain}"
      "grafana.lan"
    ];
  };

  hosts = {
    Hephaestus = {
      domains = [
        "hephaestus.${local-domain}"
        "hephaestus.lan"
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
        "metrics.lan"
      ]
        ++ prometheus.domains
        ++ grafana.domains;
    };
  };
}
