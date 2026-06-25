pkgs:
  removeAttrs (builtins.readDir ./.) [ "default.nix" ]
  |> builtins.mapAttrs (name: value: pkgs.callPackage ./${name} {})

