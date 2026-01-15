{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../keymaps
    ../../modules/pipewire-low-latency.nix
  ];

  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    inputs.nix-gaming.overlays.default
  ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
  boot.kernelParams = [
    "video=DP-2:2560x1440@180"
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

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-desktop";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Prague";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL		= "en_US.UTF-8";
      LC_CTYPE		= "cs_CZ.UTF-8";
      LC_ADDRESS	= "cs_CZ.UTF-8";
      LC_MEASUREMENT	= "cs_CZ.UTF-8";
      LC_MESSAGES	= "en_US.UTF-8";
      LC_MONETARY	= "cs_CZ.UTF-8";
      LC_NAME		= "cs_CZ.UTF-8";
      LC_NUMERIC	= "cs_CZ.UTF-8";
      LC_PAPER		= "cs_CZ.UTF-8";
      LC_TELEPHONE	= "cs_CZ.UTF-8";
      LC_TIME		= "cs_CZ.UTF-8";
      LC_COLLATE	= "cs_CZ.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # real-time support
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    xterm
    net-tools
  ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  services.xserver = {
    enable = false;
    xkb.layout = "cz-winlike";
    videoDrivers = [ "nvidia" ];
  };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  system.stateVersion = "25.11";
}
