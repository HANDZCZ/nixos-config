{ host-info, ... }:

{
  # Mount secrets for this microvm
  microvm.shares = [
    rec {
      proto = "virtiofs";
      cache = "never";
      tag = "vm-sops-nix";
      source = "/run/secrets/vms/${host-info.vm-name}";
      mountPoint = source;
      readOnly = true;
    }
  ];
}
