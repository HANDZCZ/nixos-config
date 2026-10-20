{ config, pkgs, lib, ... }:

let
  usesSystemd = config.sops.useSystemdActivation;
in {
  systemd.services."stable-secrets-sync" = {
    description = "Sync decrypted secrets into stable path for virtiofsd";
    serviceConfig = {
      Type = "oneshot";
    };

    # When using systemd service add config for it
    after = [ "local-fs.target" ]
     ++ lib.optional usesSystemd "sops-install-secrets.service";
    requires = lib.optional usesSystemd "sops-install-secrets.service";

    # Run on every activation
    requiredBy = [ "sysinit-reactivation.target" ];
    before = [ "sysinit-reactivation.target" ];
    # Run on boot, before any program that needs it starts
    wantedBy = [ "sysinit.target" ];

    path = with pkgs; [
      rsync
    ];

    script = ''
      rsync -a --delete /run/secrets/ /run/stable-secrets/
    '';
  };
}
