{ ... }:

{
  imports = [
    ../../modules/pihole.nix
    ../../modules/dnscrypt-proxy.nix
  ];

  services.pihole-ftl = {
    settings = {
      #misc.readOnly = false;
      dns = {
        upstreams = [ "127.0.0.1#1053" ];
        revServers = [];
        hosts = [];
        cnameRecords = [];
        #interface = "eth0";
      };
    };
  };

  services.dnscrypt-proxy = {
    listenOn = [ "127.0.0.1:1053" ];
    ipv6Support = false;
    useCache = false; # handled by pihole
    webui = {
      enable = true;
      openFirewall = true;
    };
  };
}
