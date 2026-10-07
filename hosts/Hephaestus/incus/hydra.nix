{ vm-name, mkNet, mkShares, ... }:
{ flake, networks, pkgs, ... }:

let
  vm-conf = flake.nixosConfigurations."${vm-name}-vm";
  metadata = vm-conf.config.system.build.metadata + "/tarball/nixos.tar.xz";
  image = vm-conf.config.system.build.qemuImage + "/nixos.qcow2";

  imageName = "nixos/custom/${vm-name}";

  diskSize = "250GiB";
  ram = "8GiB";
  cpus = 24;

  shares = mkShares {
    inherit vm-name;
    shares = {};
  };
in {
  imports = [
    shares.hostImport
  ];

  incus.instances.${vm-name}.drv = pkgs.writeShellScriptBin "incus-init-vm-hydra" ''
    set -euo pipefail

    if ! incus image show ${imageName} &>/dev/null; then
      echo "Importing ${vm-name} image as ${imageName}"
      incus image import --alias ${imageName} "${metadata}" "${image}"
    fi

    # Create vm if it does not exist already
    if ! incus info ${vm-name} &>/dev/null; then
      echo "Creating vm ${vm-name} from image ${imageName}"
      incus create --vm ${imageName} ${vm-name} \
        -c security.secureboot=false \
        --no-profiles \
        --device root,size=${diskSize}
      created_vm=true
    fi

    echo "Configuring vm ${vm-name}";
    echo "  -> Adding networks";
    ${mkNet {
      net = networks.servers;
      mac = "2a:30:33:66:cd:aa";
      inherit vm-name;
    }}
    echo "  -> Adding shares";
    ${shares.incusCommands}
    echo "  -> Setting limits";
    incus config set ${vm-name} limits.memory=${ram}
    incus config set ${vm-name} limits.cpu=${toString cpus}

    # Only start the vm if it was just created by this script
    if [ "''${created_vm:-false}" = "true" ]; then
      echo "Starting vm ${vm-name}";
      incus start ${vm-name}
    fi
  '';
}
