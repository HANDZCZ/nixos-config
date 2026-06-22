{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "";
      };
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.follows = "noctalia-qs";
      };
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-nixcord.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
      };
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
      };
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks.inputs = {
          nixpkgs.follows = "nixpkgs";
          flake-compat.follows = "flake-compat";
        };
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        niri-unstable.follows = "";
        xwayland-satellite-unstable.follows = "";
      };
    };

    nix-tools-steam = {
      url = "github:HANDZCZ/nix-tools-steam";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian" # nix-cachyos-kernel
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # nix-cachyos-kernel
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, ... }: {
    nixosConfigurations = {
      nixos-desktop =
        let
          system = "x86_64-linux";
          set-nixPath = { inputs, ... }: {
            nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          };
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            overlays = with inputs; [
              nix-cachyos-kernel.overlays.pinned
              nix-gaming.overlays.default
              nix-vscode-extensions.overlays.default
            ];
            inherit system;
          };
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            inherit system;
          };
        in nixpkgs.lib.nixosSystem {
          inherit pkgs;
          specialArgs = { inherit inputs pkgs-unstable; };
          modules = [
            ./hosts/desktop
            set-nixPath
          ];
        };
    };
  };
}
