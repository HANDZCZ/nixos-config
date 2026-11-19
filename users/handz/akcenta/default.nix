{ lib, ... }:

{
  imports = removeAttrs (builtins.readDir ./.) [ "default.nix" ]
    |> lib.mapAttrsToList (name: _: import ./${name});
}
