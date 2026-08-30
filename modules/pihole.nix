{ config, lib, ... }:

let
  cfg-ftl = config.services.pihole-ftl;
in {
  options.services.pihole-ftl.openFirewallDNS' = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Open ports in the firewall for pihole-FTL's DNS server.";
  };

  config.services.pihole-ftl = {
    enable = true;
    openFirewallDNS = lib.mkForce false;
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        description = "";
      }
      {
        url = "https://big.oisd.nl";
        description = "https://oisd.nl/";
      }
      {
        url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/regex.list";
        description = "PiHole Blocklist SmartTV https://github.com/Perflyst/PiHoleBlocklist/";
      }
      {
        url = "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/newhosts-final.hosts";
        description = "CPBL Hosts https://github.com/bongochong/CombinedPrivacyBlockLists";
      }
      {
        url = "https://adaway.org/hosts.txt";
        description = "AdAway";
      }
      {
        url = "https://raw.githubusercontent.com/badmojr/1Hosts/refs/heads/master/Lite/domains.txt";
        description = "https://github.com/badmojr/1Hosts";
      }
    ];
    useDnsmasqConfig = lib.mkDefault false;
    settings = {
      #misc.readOnly = false;
      dns = {
        #upstreams = [];
        #revServers = [];
        #hosts = [];
        #cnameRecords = [];
        #interface = "eth0";
        dnssec = lib.mkDefault true;
        domainNeeded = true;
        listeningMode = lib.mkDefault "SINGLE";
        port = lib.mkDefault 53;

        domain = {
          name = lib.mkDefault "lan";
          local = lib.mkDefault true;
        };
        cache = {
          size = 10000;
          upstreamBlockedTTL = 1*60*60;
        };
        rateLimit = {
          count = 1000;
          interval = 60;
        };
      };
      dhcp.active = false;
      ntp = {
        ipv4.active = false;
        ipv6.active = false;
        sync.active = false;
      };
      webserver = {
        api.pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$pXJv3j13aiX5YnCrDiPVfA==$TMKMtMHrYtme6aJBAGbRnfIyy2Dxx6KyZ/wHjdh6x60=";
        interface = {
          boxed = true;
          theme = "default-dark";
        };
      };
    };
  };

  config.services.pihole-web = {
    enable = lib.mkDefault true;
    ports = lib.mkDefault [ "8012" ];
  };

  config.networking.firewall = let
    dns-port = cfg-ftl.settings.dns.port;
  in lib.mkIf (lib.attrByPath [ "dns" "port" ] null cfg-ftl.settings != null && cfg-ftl.openFirewallDNS') {
    allowedUDPPorts = [ dns-port ];
    allowedTCPPorts = [ dns-port ];
  };
}

