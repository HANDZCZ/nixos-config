{ the-cfg, host-info, host-cfg,... }:

{
  imports = [
    ./secrets.nix
    ../ddns-nsupdate.nix
  ];

  services.ddns-nsupdate = {
    enable = true;
    domains = {
      ${the-cfg.vms.${host-info.hostName}.fqdn} = {
        server = the-cfg.dns.primary.ip;
        # NOTE: pull path from host so we get and error if it does not exist
        key = host-cfg.sops.secrets."vms/${host-info.vm-name}/dns-tsig-key".path;
      };
    };
  };
}
