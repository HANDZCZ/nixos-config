{ config, inputs, lib, flake,... }:

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

  # Add default prometheus node exporter to all microvms
  mkMicrovmConfig' = { config, ... }@args: mkMicrovmConfig (args // {
    config = {
      imports = [
        config
        ./metrics/node-exporter.nix
      ];
    };
  });

  # FIXME: use more robust discovery mechanism than hostname from dhcp
  prometheus-cfg.scrapeConfigs = [
    {
      job_name = "microvms-node";
      static_configs = [
        {
          targets = config.microvm.vms
            |> lib.mapAttrsToList (name: cfg: let
                vm-cfg = cfg.config.config;
              in "${vm-cfg.networking.hostName}:${toString vm-cfg.services.prometheus.exporters.node.port}"
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
