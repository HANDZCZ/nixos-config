{
  inputs,
}:

rec {
  default_overlays = with inputs; [
    nix-cachyos-kernel.overlays.pinned
    nix-gaming.overlays.default
    nix-vscode-extensions.overlays.default
    (final: prev: import ../packages prev)
  ] ++ (import ../overlays inputs.nixpkgs.lib);

  default_modules = [
    ../keymaps
    ../modules/bootloader.nix
    ../modules/ntsync.nix
    ../modules/ccache.nix
    ../modules/tz_locale.nix
    ../modules/dell-fancontrol.nix
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
          memorySize = lib.mkDefault 8192; # MiB
          cores = lib.mkDefault 6;
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
      inherit system;
      overlays = overlays ++ [
        (final: prev: { inherit pkgs-unstable; })
      ];
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

  mkMicrovmConfig = {
    host-info,
    root ? {},
    networks,
    config ? {},
  }: { lib, ... }: {
    imports = [
      inputs.microvm.nixosModules.microvm
      config
    ];

    _module.args = {
      inherit host-info inputs;
      networks = networks
        |> lib.mapAttrs (name: val: {
          interface = name;
        });
    };

    systemd.network = {
      enable = true;

      # Rename interfaces
      links = networks |> lib.mapAttrs' (key: val: lib.nameValuePair "10-${key}" {
        matchConfig.PermanentMACAddress = val.mac;
        linkConfig.Name = key;
      });
    };

    services.openssh = {
      enable = true;
      # By default allow access from host through VSOCK only
      openFirewall = lib.mkDefault false;
    };

    users.users.root = {
      password = lib.mkIf (root ? password) root.password;
      openssh.authorizedKeys.keys = lib.mkIf (root ? authorizedKeys) root.authorizedKeys;
    };

    services.openssh.settings = lib.mkIf (root ? sshWithPass && root.sshWithPass) {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };

    # Reduce journal size
    services.journald = {
      extraConfig = ''
        Storage=persistent
        SystemMaxUse=128M
        SystemMaxFileSize=16M
        SystemMaxFiles=8
        RuntimeMaxUse=16M
        RuntimeMaxFileSize=4M
        Compress=yes
        MaxRetentionSec=7d
      '';
      rateLimitBurst = 2000;
    };

    microvm = {
      vsock.cid = host-info.hostName
        |> lib.hashString "sha256"
        |> lib.substring 0 8
        |> lib.fromHexString;
      hypervisor = lib.mkDefault "cloud-hypervisor";
      mem = lib.mkDefault 512;
      hotplugMem = lib.mkDefault 2048;
      hotpluggedMem = lib.mkDefault 0;
      balloon = lib.mkDefault true;
      deflateOnOOM = true;
      storeDiskDirect = true;
      shares = [
        {
          proto = "virtiofs";
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          readOnly = true;
        }
        {
          proto = "virtiofs";
          tag = "journal";
          source = "/var/lib/microvms/${host-info.hostName}/journal";
          mountPoint = "/var/log/journal";
        }
      ];
      interfaces = networks
        |> lib.attrValues
        |> lib.map (net:
          lib.removeAttrs net [ "mkId" ]
            // (
              if net ? mkId
                then { id = net.mkId host-info.hostName; }
                else {}
            )
        );
    };

    networking.hostName = host-info.hostName;
    system.stateVersion = "25.11";
  };
}
