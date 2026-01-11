{ ... }:

let
  includes' = [
    {
      condition = [
        "hasconfig:remote.*.url:https://gitlab.com/**"
        "hasconfig:remote.*.url:git@gitlab.com:*/**"
        "hasconfig:remote.*.url:https://git.handz.eu.org/**"
        "hasconfig:remote.*.url:ssh://git@git-ssh.handz.eu.org:222/**"
        "hasconfig:remote.*.url:git@ssh.suyu.dev:*/**"
      ];
      contents = {
        user = {
          name = "HANDZ";
        };
      };
    }
  ];
in {
  xdg.configFile."git/allowed-signers".text = ''
    handz@email.cz ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENuL8sNTHVB/UOfB1pSiCn3CiDkm0ozGSvM3imwVwlj handz@DESKTOP-1OPEM0P
  '';
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "HANDZCZ";
        email = "handz@email.cz";
      };
      credential.helper = "store";
      core.autocrlf = false;
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed-signers";
    };
    signing = {
      format = "ssh";
      signByDefault = true;
      key = "~/.ssh/git/id_ed25519_signing_key";
    };
    includes =
      builtins.concatMap (inc:
        map
          (cond: {
            condition = cond;
            contents = inc.contents;
          })
          inc.condition
      )
      includes';
  };


  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_github.com" ];
      };
      "gitlab.com" = {
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_gitlab.com" ];
      };
      "git-ssh.handz.eu.org" = {
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_git-ssh.handz.eu.org" ];
      };
      "ssh.suyu.dev" = {
        user = "git";
        identityFile = [ "~/.ssh/git/id_ed25519_ssh.suyu.dev" ];
      };
    };
  };
}
