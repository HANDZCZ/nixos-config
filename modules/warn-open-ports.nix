{ config, lib, ... }:

{
  warnings = let
    fw-cfg = config.networking.firewall;
    mkPortWarn = proto: port: "${proto} ${toString port} is allowed on all interfaces!";
  in lib.map (port: mkPortWarn "TCP" port) fw-cfg.allowedTCPPorts
    ++ lib.map (port: mkPortWarn "TCP" port) fw-cfg.allowedTCPPortRanges
    ++ lib.map (port: mkPortWarn "UDP" port) fw-cfg.allowedUDPPorts
    ++ lib.map (port: mkPortWarn "UDP" port) fw-cfg.allowedUDPPortRanges;
}
