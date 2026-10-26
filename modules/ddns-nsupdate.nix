{ config, pkgs, lib, ... }:

let
  cfg = config.services.ddns-nsupdate;
in {
  options.services.ddns-nsupdate = {
    enable = lib.mkEnableOption "Dynamic DNS updates through nsupdate (RFC 2136)";
    package = lib.mkPackageOption pkgs "ddns-nsupdate" {};
    domains = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          server = lib.mkOption {
            type = lib.types.str;
            description = "DNS server to send the update to.";
          };
          zone = lib.mkOption {
            type = lib.types.oneOf [
              (lib.types.enum [ "FQDN" "SOA" ])
              (lib.types.strMatching "^[a-z0-9.-]*[a-z0-9]$")
            ];
            default = "FQDN";
            description = ''
              Zone to update.
              - "FQDN" (default): use FQDN as the zone
              - "SOA": let nsupdate auto-detect via SOA query
              - any other value: used as the zone name explicitly
            '';
          };
          interface = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Network interface to read the IP from. If null, all interfaces are used.";
          };
          ttl = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "TTL for the DNS records.";
          };
          key = lib.mkOption {
            type = lib.types.str;
            description = "Path to the TSIG key file.";
          };
        };
      });
      default = { };
      description = "Set of domains to update. Keys are FQDNs.";
    };
    timer = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "a periodic timer for ddns-nsupdate";
          interval = lib.mkOption {
            type = lib.types.str;
            default = "1h";
            description = "How often to run the update (systemd timer syntax).";
          };
        };
      };
      default = { enable = true; };
      description = "Periodic timer configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ddns-nsupdate = {
      description = "Dynamic DNS update via nsupdate";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = let
        mkCmd = domain: conf: let
          iface = if conf.interface != null then "-i ${conf.interface}" else "-a";
          zone =
            if conf.zone == "SOA" then ""
            else if conf.zone == "FQDN" then "-z ${domain}"
            else "-z ${conf.zone}";
        in ''${lib.getExe cfg.package} -f ${domain} -s ${conf.server} -k "${conf.key}" -t ${toString conf.ttl} ${iface} ${zone}'';
        cmds = cfg.domains
          |> lib.mapAttrsToList mkCmd
          |> lib.concatLines;
      in ''
        ${cmds}
      '';
    };

    services.networkd-dispatcher = {
      enable = true;
      rules."ddns-nsupdate" = {
        onState = [ "routable" ];
        script = "sleep 20 && systemctl restart ddns-nsupdate";
      };
    };

    systemd.timers.ddns-nsupdate = lib.mkIf cfg.timer.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.timer.interval;
        AccuracySec = "1min";
        Unit = "ddns-nsupdate.service";
      };
    };
  };
}
