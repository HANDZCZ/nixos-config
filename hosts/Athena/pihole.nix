{ ... }:

{
  imports = [
    ../../modules/pihole.nix
  ];

  services.pihole-ftl = {
    settings = {
      #misc.readOnly = false;
      dns = {
        upstreams = [ "1.1.1.1" ];
        revServers = [];
        hosts = [];
        cnameRecords = [];
        #interface = "eth0";
      };
    };
  };
}
