{
  inputs,
}:

rec {
  default_overlays = with inputs; [
    nix-cachyos-kernel.overlays.pinned
    nix-gaming.overlays.default
    nix-vscode-extensions.overlays.default
    (final: prev: import ../packages prev)
  ];

  default_modules = [
    # Misc
    ({ pkgs, pkgs-unstable, lib, host-info, ... }: {
      # following configuration is added only when building VM with build-vm
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize =  8192; # MiB
          cores = 6;
        };
      };
    })
  ];

  mkHostConfig = {
    system ? "x86_64-linux",
    folder,
    host-info ? {
      hostName = "nixos-${folder}";
    },
    overlays ? default_overlays,
    modules ? default_modules,
    ...
  }: let
    pkgs = import inputs.nixpkgs {
      config.allowUnfree = true;
      inherit system overlays;
    };
    pkgs-unstable = import inputs.nixpkgs-unstable {
      config.allowUnfree = true;
      inherit system;
    };
  in inputs.nixpkgs.lib.nixosSystem {
    inherit pkgs;
    specialArgs = { inherit inputs pkgs-unstable host-info; };
    modules = [
      ./${folder}
      { nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; }
    ] ++ modules;
  };
}
