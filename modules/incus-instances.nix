{ lib, pkgs, ... }:

{
  options.incus.instances = lib.mkOption {
    default = {};
    description = ''
      When instance's activate is called like so:
        nix run .#nixosConfigurations.<INCUS_HOST>.config.incus.instances.<NAME>.activate <SSH host>

      The drv is built localy and then copied over ssh to remote, where it is ran.
      Main usage is to define drv that references the incus metadata + image and imports it into incus.
      It can also create and configure the instances.
    '';
    type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: { options = {
      drv = lib.mkOption {
        default = null;
        type = lib.types.package;
      };
      activate = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellScriptBin "activate-${name}" ''
          set -euo pipefail

          usage() {
            echo "Usage: activate-${name} <host>"
            echo ""
            echo "Copy and activate the NixOS configuration on the given host."
            echo ""
            echo "Arguments:"
            echo "    <host>    SSH host (user@host or host alias from ~/.ssh/config)"
            echo ""
            echo "Options:"
            echo "    -h, --help    Show this help message"
          }

          if [[ $# -eq 0 ]] || [[ "$1" == "-h" || "$1" == "--help" ]]; then
            usage >&2
            [[ $# -eq 0 ]] && exit 1 || exit 0
          fi

          if [[ $# -ne 1 ]]; then
            echo "Error: expected exactly 1 argument, got $#." >&2
            usage >&2
            exit 1
          fi

          host="$1"

          echo "Copying clousure to $host" >&2
          ${lib.getExe pkgs.nix} copy --no-check-sigs --to "ssh-ng://$host" ${config.drv}

          echo "Activating on $host" >&2
          ${lib.getExe pkgs.openssh} -t "$host" sudo ${lib.getExe config.drv}
        '';
        readOnly = true;
      };
    };}));
  };
}
