{ config, ... }:

let
  kernelPackages = config.boot.kernelPackages;
  zfs-attrib = config.boot.zfs.package.kernelModuleAttribute;
in {
  assertions = [{
    assertion = (builtins.tryEval kernelPackages).success && !kernelPackages.${zfs-attrib}.meta.broken;
    message = "Current kernel packages don't support zfs!";
  }];
}
