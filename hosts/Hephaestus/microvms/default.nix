{ config, inputs, lib, flake, the-cfg,... }:

let
  host-cfg = config;
  inherit (import ../../default.nix { inherit inputs flake; }) mkMicrovmConfig;
  mkNet = {
    net,
    mac,
    prefix ? "br-",
    posfix ? ""
  }: {
    "${prefix}${net.name}${posfix}" = {
      type = "tap";
      inherit mac;
      inherit (net.microvm) mkId;
    };
  };

  root-conf = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcwNg4M4I5wH4Oh2uaTvGDiVOw/kScEXvKzqX+hNKAD root@Hephaestus"
    ];
  };

  mkMicrovmConfig' = { config, ... }@args: mkMicrovmConfig (args // {
    config = { host-info, ... }: {
      imports = [
        config
        # Add default prometheus node exporter to all microvms
        ../../../modules/microvm/node-exporter.nix
        # Add ddns to all microvms
        ../../../modules/microvm/ddns.nix
      ];

      # Set fqdn for this vm
      networking.fqdn = lib.head the-cfg.vms.${host-info.vm-name}.domains;

      _module.args = {
        inherit
          # Add config attrs for vms/hosts/services
          the-cfg
          # Add host config so microvms can access config of the actual host
          host-cfg;
      };

    };
  });

  prometheus-cfg.scrapeConfigs = [
    {
      job_name = "host-node";
      static_configs = [
        {
          targets = [
            "${config.networking.fqdn}:${toString config.services.prometheus.exporters.node.port}"
          ];
        }
      ];
    }
    {
      job_name = "microvms-node";
      static_configs = [
        {
          targets = config.microvm.vms
            |> lib.mapAttrsToList (name: cfg: let
                vm-cfg = cfg.config.config;
              in "${vm-cfg.networking.fqdn}:${toString vm-cfg.services.prometheus.exporters.node.port}"
            );
        }
      ];
    }
  ];

  vms = builtins.readDir ./.
    |> lib.flip removeAttrs [ "default.nix" ]
    |> lib.mapAttrsToList (name: value: import ./${name} {
      vm-name = name |> lib.removeSuffix ".nix";
      mkMicrovmConfig = mkMicrovmConfig';
      inherit mkNet root-conf prometheus-cfg;
    });
in {
  imports = [
    inputs.microvm.nixosModules.host
  ] ++ vms;

  microvm = {
    host = {
      enable = true;
    };
  };
}
