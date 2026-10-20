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
    Hephaestus = rec {
      fqdn = "hephaestus.${local-domain}";
      domains = [
        fqdn
      ];
    };
  };

  vms = {
    technitium = rec {
      fqdn = lib.head domains;
      domains = services.technitium.domains;
    };
    paperless = rec {
      fqdn = lib.head domains;
      domains = services.paperless.domains;
    };
    metrics = rec {
      fqdn = "metrics.${local-domain}";
      domains = with services; [
        fqdn
      ]
        ++ prometheus.domains
        ++ grafana.domains;
    };
  };
}
