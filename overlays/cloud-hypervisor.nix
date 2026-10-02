# Use cloud cloud-hypervisor from unstable where version is >= 53.0
# Fixes longer boots when using cid in microvm.nix
final: prev: let
  unstable-pkg = final.pkgs-unstable.cloud-hypervisor;
  stable-pkg = prev.cloud-hypervisor;
  check = final.lib.versionAtLeast stable-pkg.version "53.0";
in {
  cloud-hypervisor = final.lib.warnIf check "cloud-hypervisor version is >= 53.0" unstable-pkg;
}
