{ config, inputs, lib, flake, the-cfg,... }:

let
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
    sshWithPass = true;
    password = "root";
  };

  mkMicrovmConfig' = { config, ... }@args: mkMicrovmConfig (args // {
    config = { host-info, ... }: {
      imports = [
        config
        # Add default prometheus node exporter to all microvms
        ../../../modules/microvm/node-exporter.nix
      ];

      # Add config attrs for vms/hosts/services
      _module.args = { inherit the-cfg; };

      # Set fqdn for this vm
      networking.fqdn = lib.head the-cfg.vms.${host-info.vm-name}.domains;
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
