{ lib, user-info, pkgs, ... }:

{
  imports = removeAttrs (builtins.readDir ./.) [ "default.nix" ]
    |> lib.mapAttrsToList (name: _: import ./${name});

  home-manager.users.${user-info.name} = {
    home.packages = with pkgs; [
      openshift
      kubectl
      kubectx
      kustomize
    ];
  };
}
