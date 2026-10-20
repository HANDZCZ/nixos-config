{ ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/hosts/Hephaestus.yaml;

    secrets = {
      "host/dns-tsig-key" = {};
      "host/root/ssh-key" = {
        path  = "/root/.ssh/id_ed25519";
      };

      "vms/technitium/dns-tsig-key" = {};
      "vms/metrics/dns-tsig-key" = {};
      "vms/paperless/dns-tsig-key" = {};
    };
  };
}
