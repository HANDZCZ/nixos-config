inputs: final: prev: let
  pins = {
    atuin = "18.24.8";
    mergiraf = "0.20.0";
  };
in
  inputs.multiverse.lib.pinOverlay {
    inherit pins;
    config.allowUnfree = true;
  } final prev
  |> prev.lib.mapAttrs (name: pinned-pkg: let
      stable-pkg = prev.${name};
      check = prev.lib.versionAtLeast stable-pkg.version pinned-pkg.version;
    in
      prev.lib.warnIf check "${name} version is >= ${pinned-pkg.version}" pinned-pkg
  )

