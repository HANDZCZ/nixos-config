{ ... }:

{
  boot.kernelParams = [
    "zswap.enabled=0"
  ];

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 300;      # Pop!_OS guides: 200-400 frees caches fast for zram, but 300 balances ZFS reads.
    "vm.swappiness" = 180;              # SteamOS/Bazzite: 150-180 treats zram as "RAM extension"—snappy on low loads.
    "vm.dirty_background_ratio" = 20;   # Gaming tunings: 1-5 prevents micro-lags from bursts; 2 suits light VMs.            # 20
    "vm.dirty_ratio" = 60;              # Balanced gamer mid-range—allows dirty buildup without app stalls.                  # 80
    "vm.watermark_boost_factor" = 0;    # Disables overhead (all zram sources agree).
    "vm.watermark_scale_factor" = 125;  # Proactive headroom—gamer/Proxmox default for no surprises.
    "vm.page-cluster" = 0;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}

