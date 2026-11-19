{ user-info, ... }:

{
  home-manager.users.${user-info.name}.programs.ssh = {
    settings = {
      "ocpstf.akcenta.dev" = {
        HostName = "10.10.130.50";
        user = "najmanj";
        identityFile = [ "~/.ssh/id_ed25519" ];
        LocalForward = [
          "127.10.130.50:6443 127.0.0.1:6443"
        ];
      };
    };
  };
}
