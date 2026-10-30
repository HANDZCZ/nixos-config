{ ... }:

{
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelParams = [ "zfs.zfs_arc_max=2147483648" ];
  };

  boot.zfs = {
    devNodes = "/dev/disk/by-id";
    forceImportRoot = false;
  };

  services.zfs.trim.enable = true;
  services.zfs.autoScrub = {
    enable = true;
  };
}
