{ ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/hosts/Hephaestus.yaml;

    secrets = {
      "host/dns-tsig-key" = {};

      "vms/technitium/dns-tsig-key" = {};
      "vms/metrics/dns-tsig-key" = {};
      "vms/paperless/dns-tsig-key" = {};
    };
  };
}
