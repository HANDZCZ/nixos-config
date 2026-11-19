{ user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    xdg.configFile."git/allowed-signers".text = ''
      jan.najman@akcenta.eu ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxqYUhbtki4U7cMl+uXMtumc9HDV5Jw3r4O1RhAK86I handz@Behemoth
    '';

    programs.git.includes = [
      {
        condition = "gitdir:~/Projects/Akcenta/**";
        contents = {
          user = {
            name = "Jan Najman";
            email = "jan.najman@akcenta.eu";
            signingKey = "~/.ssh/git/id_ed25519_akcz_signing_key";
          };
          url."git@github-akcz:".insteadOf = "git@github.com:";
        };
      }
    ];

    programs.ssh.settings = {
      "github-akcz" = {
        HostName = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_akcz_github.com" ];
      };
      "gitlabdev.akcenta.eu" = {
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_akcz_gitlabdev.akcenta.eu" ];
      };
    };
  };
}
