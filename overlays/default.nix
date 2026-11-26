inputs:
  removeAttrs (builtins.readDir ./.) [ "default.nix" ]
  |> inputs.nixpkgs.lib.mapAttrsToList (name: _: import ./${name} inputs)
