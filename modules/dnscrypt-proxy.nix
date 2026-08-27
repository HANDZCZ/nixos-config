{ config, lib, ... }:

let
  cfg = config.services.dnscrypt-proxy;
in {
  options.services.dnscrypt-proxy = {
    ipv6Support = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable IPv6 support.";
    };
    useCache = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the use of cache.";
    };
    listenOn = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "0.0.0.0:53" ];
      description = "On what addresses will the server listen for requests.";
    };

    webui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable webui.";
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0:8015";
        description = "On what addresses will the webui be accessible.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open firewall for webui.";
      };
    };
  };

  config.services.dnscrypt-proxy = {
    enable = true;
    settings = {
      query_log = {
        #file = "/dev/stdout";
        ignored_qtypes = [];
      };

      server_names =
        config.services.dnscrypt-proxy.settings.anonymized_dns.routes
        |> lib.map (route: route.server_name);

      listen_addresses = cfg.listenOn;
      ipv6_servers = cfg.ipv6Support;
      dnscrypt_servers = true;
      doh_servers = false;
      odoh_servers = false;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
      block_ipv6 = cfg.ipv6Support;
      cache = cfg.useCache;
      anonymized_dns = {
        skip_incompatible = true;
        routes = [
          { server_name = "dnscry.pt-prague-ipv4"; via = [ "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "cs-hungary"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "dnscry.pt-dusseldorf03-ipv4"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-hungary" ]; }
          { server_name = "cs-dus"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "dnscry.pt-amsterdam03-ipv4"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "dnscry.pt-jena-ipv4"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-dus" "anon-cs-hungary" ]; }
          { server_name = "ksol.io-ns2-dnscrypt-ipv4"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "dct-de"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-hungary" ]; }
          { server_name = "serbica"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "dnscry.pt-molln-ipv4"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-hungary" ]; }
          { server_name = "cs-nl"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "cs-ch"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
          { server_name = "cs-ro"; via = [ "dnscry.pt-anon-prague-ipv4" "anon-cs-de" "anon-cs-dus" "anon-cs-hungary" "dnscry.pt-anon-jena-ipv4" ]; }
        ];
      };

      monitoring_ui = {
        enabled = cfg.webui.enable;
        listen_address = cfg.webui.address;
        username = "";
        password = "";
        privacy_level = 3;
      };
    };
  };

  config.networking.firewall = let
    webui-port = cfg.webui.address |> lib.splitString ":" |> lib.last |> lib.toInt;
  in lib.mkIf cfg.enable {
    allowedTCPPorts = lib.optional cfg.webui.openFirewall webui-port;
  };
}

