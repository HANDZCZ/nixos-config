{ networks, ... }:

{
  imports = [
    ../../modules/dnscrypt-proxy.nix
  ];

  # We don't need resolved since we are running our own DNS server
  services.resolved.enable = false;
  # Add technitium to DNS servers, so we have DNS
  networking.nameservers = [ "127.0.0.1" ];

  services.technitium-dns-server = {
    enable = true;
  };

  systemd.services.technitium-dns-server.environment = {
    DNS_SERVER_FORWARDERS = "127.0.0.1:1053";
    DNS_SERVER_FORWARDER_PROTOCOL = "udp";
    DNS_SERVER_LOG_USING_LOCAL_TIME = "false";
  };

  services.dnscrypt-proxy = {
    listenOn = [ "127.0.0.1:1053" ];
    ipv6Support = false;
    useCache = false; # handled by technitium
    webui.enable = true;
  };

  networking.firewall.interfaces = {
    # 53 - technitium dns
    # 5380, 53443 - technitium web
    # 8015 - dnscrypt-proxy webui
    "${networks.servers.interface}" = {
      allowedTCPPorts = [ 53 5380 53443 8015 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
