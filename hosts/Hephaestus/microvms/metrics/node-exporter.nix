{ lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = lib.mkDefault true;

    enabledCollectors = [];

    disabledCollectors = [
      "arp"
      "bcache"
      "bonding"
      "dmi"
      "dmmultipath"
      "edac"
      "fibrechannel"
      "hwmon"
      "infiniband"
      "ipvs"
      "mdadm"
      "nfs"
      "nfsd"
      "nvme"
      "powersupplyclass"
      "rapl"
      "tapestats"
      "textfile"
      "thermal_zone"
      "watchdog"
      "xfs"
    ];
  };
}
