{ lib }:

let
  domain = "handz.eu.org";
  designation = "ce";
  local-domain = "${designation}.${domain}";

  mkMachineEntry = { name, ... }@args: {
    ${name} = {
      fqdn = "${lib.toLower name}.${designation}.machine";
      services = {};
    } // lib.removeAttrs args [ "name" ];
  };
in rec {

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

  hosts = {}
    // mkMachineEntry {
      name = "Hephaestus";
    };

  vms = {}
    // mkMachineEntry {
      name = "technitium";
      services = {
        inherit (services)
          technitium;
      };
    }
    // mkMachineEntry {
      name = "paperless";
      services = {
        inherit (services)
          paperless;
      };
    }
    // mkMachineEntry {
      name = "metrics";
      services = {
        inherit (services)
          prometheus
          grafana;
      };
    };
}
