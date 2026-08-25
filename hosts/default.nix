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
    ../keymaps
    ../modules/bootloader.nix
    ../modules/ntsync.nix
    ../modules/ccache.nix
    ../modules/tz_locale.nix
    # Misc
    ({ pkgs, pkgs-unstable, lib, host-info, ... }: {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-gaming.nixosModules.platformOptimizations
        inputs.nix-tools-steam.nixosModules.hv-bypass
      ];

      networking.hostName = host-info.hostName;

      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = lib.mkDefault true;
      };

      # Default packages
      environment.systemPackages = with pkgs; [
        neovim
        wget
        curl
        git
        xterm
        net-tools
        dig
        openssh
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        sharedModules = [
          inputs.niri-nix.homeModules.default
          inputs.noctalia.homeModules.default
          inputs.nixvim.homeModules.nixvim
          inputs.nixcord.homeModules.nixcord
        ];
        extraSpecialArgs = {
          inherit inputs pkgs-unstable host-info;
        };
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
        auto-optimise-store = true;
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

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
