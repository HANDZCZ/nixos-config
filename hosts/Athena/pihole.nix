{ networks, ... }:

{
  imports = [
    ../../modules/pihole.nix
    ../../modules/dnscrypt-proxy.nix
  ];

  # We don't need resolved since we are running out own DNS server
  services.resolved.enable = false;
  # Add pihole to DNS servers so we have DNS
  networking.nameservers = [ "127.0.0.1" ];

  services.pihole-ftl = {
    settings = {
      #misc.readOnly = false;
      dns = {
        upstreams = [ "127.0.0.1#1053" ];
        revServers = [
          "true,10.10.0.0/16,10.10.5.1,lan"
        ];
        hosts = [];
        cnameRecords = [];
        interface = "${networks.servers}";
      };
    };
  };

  services.dnscrypt-proxy = {
    listenOn = [ "127.0.0.1:1053" ];
    ipv6Support = false;
    useCache = false; # handled by pihole
    webui.enable = true;
  };

  networking.firewall.interfaces = {
    # 53 - pihole dns
    # 8012 - pohole web
    # 8015 - dnscrypt-proxy webui
    "${networks.servers}" = {
      allowedTCPPorts = [ 53 8012 8015 ];
      allowedUDPPorts = [ 53 ];
    };
    "${networks.lan}" = {
      allowedTCPPorts = [ 8012 8015 ];
    };
  };
}
