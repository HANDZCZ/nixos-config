{ host-info, ... }:

{
  # Mount secrets for this microvm
  # NOTE: use the /run/stable-secrets because virtiofsd can't handle secret updates via symlinks
  microvm.shares = [
    {
      proto = "virtiofs";
      cache = "never";
      tag = "vm-sops-nix";
      source = "/run/stable-secrets/vms/${host-info.vm-name}";
      mountPoint = "/run/secrets/vms/${host-info.vm-name}";
      readOnly = true;
    }
  ];
}
