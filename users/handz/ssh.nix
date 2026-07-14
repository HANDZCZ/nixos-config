{ user-info, ... }:

{
  home-manager.users.${user-info.name}.programs.ssh = {
    enable = true;
    # silences the warning
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = false;
        Compression = false;
        ControlMaster = false;
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = false;
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
