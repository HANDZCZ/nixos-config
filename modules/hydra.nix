{ config, lib, ... }:

{
  services.hydra = {
    enable = true;
    useSubstitutes = true;
    hydraURL = lib.mkDefault "http://localhost:${toString config.services.hydra.port}";
    notificationSender = lib.mkDefault "hydra@localhost";
    extraConfig = ''
      <git-input>
        timeout = 3600
      </git-input>
    '';
  };
}
