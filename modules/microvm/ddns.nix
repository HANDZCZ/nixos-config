{ config, lib, the-cfg, host-info, host-cfg,... }:

let
  cfg = config.vm.ddns-nsupdate;
in {
  imports = [
    ./secrets.nix
    ../ddns-nsupdate.nix
  ];

  options.vm.ddns-nsupdate.add-fqdn = lib.mkEnableOption "add FQDN to domains";

  config = lib.mkIf cfg.add-fqdn {
    # Needed for dns TSIG key
    vm.secrets.enable = true;

    services.ddns-nsupdate = {
      # Enable ddns-nsupdate by default
      enable = lib.mkDefault true;
      domains = {
        ${the-cfg.vms.${host-info.hostName}.fqdn} = {
          server = the-cfg.dns.primary.ip;
          # NOTE: pull path from host so we get and error if it does not exist
          key = host-cfg.sops.secrets."vms/${host-info.vm-name}/dns-tsig-key".path;
        };
      };
    };
  };
}
