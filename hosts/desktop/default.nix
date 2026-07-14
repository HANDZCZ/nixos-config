{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/pipewire-low-latency.nix
    ../../modules/zramSwap.nix
    ../../modules/nvidia.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
  kernel.ntsync.enable = true;
  boot.kernelPackages = let
    system = pkgs.stdenv.hostPlatform.system;
    kernel-flake = inputs.nix-cachyos-kernel;
    kernel-nixpkgs = import kernel-flake.inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowInsecurePredicate = _: true;
      };
    };
    kernel-pkgs = kernel-flake.legacyPackages.${system};
    helpers = kernel-nixpkgs.callPackage "${kernel-flake.outPath}/helpers.nix" {};

    kernel = kernel-pkgs.linux-cachyos-bore-lto-x86_64-v3;

    kernel-with-ccache = kernel.override (prev: if !config.programs.ccache.enable then {} else rec {
      stdenv = pkgs.ccacheStdenv.override {
        stdenv = helpers.stdenvLLVM;
      };
      extraMakeFlags = [
        "CC=${stdenv.cc}/bin/clang"
        # NOTE: setting LD (maybe HOSTLD too) causes error: ld.lld: error: The setup header has the wrong offset!
        #       even though wrapped variant of it exists
        #"LD=${stdenv.cc}/bin/ld.lld"
        #"HOSTLD=${stdenv.cc}/bin/ld.lld"
        "AR=${stdenv.cc}/bin/ar"
        "HOSTAR=${stdenv.cc}/bin/ar"
        "NM=${stdenv.cc}/bin/nm"
        "STRIP=${stdenv.cc}/bin/strip"
        "OBJCOPY=${stdenv.cc}/bin/objcopy"
        "OBJDUMP=${stdenv.cc}/bin/objdump"
        "READELF=${stdenv.cc}/bin/readelf"
        "HOSTCC=${stdenv.cc}/bin/clang"
        "HOSTCXX=${stdenv.cc}/bin/clang++"
      ];
    });
  in helpers.kernelModuleLLVMOverride (kernel-nixpkgs.linuxKernel.packagesFor kernel-with-ccache);

  boot.kernelParams = [
    "video=DP-2:2560x1440@180"
  ];

  services.beesd.filesystems = let
    mkFsConf = label: size: {
      "${label}" = {
        spec = "LABEL=${label}";
        hashTableSizeMB = size;
        extraOptions = [
          "--loadavg-target" "16.0"
          "--thread-factor" "0.75"
          "--throttle-factor" "1.0"
        ];
      };
    };
  in {}
    // mkFsConf "data" 512
    // mkFsConf "data-1TB" 512;

  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  networking = {
    interfaces = {
      enp39s0 = {
        wakeOnLan = {
          enable = true;
          policy = [
            "magic"
          ];
        };
      };
    };
    firewall = {
      allowedUDPPorts = [ 9 ];
    };
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
    # NOTE: disable compression and use btrfs compression instead - no double compress
    #       enable file_clone to take advantage of btrfs CoW
    #       also increase cache size to account for the increased uncompressed cache size
    extraConfig = ''
      compression = false
      file_clone = true
      max_size = 25G
      sloppiness = random_seed
      umask = 007
      compiler_check = content
    '';
  };

  services.lact = {
    enable = true;
    settings = {
      version = 5;
      daemon = {
        log_level = "info";
        admin_group = "wheel";
        disable_clocks_cleanup = false;
      };
      apply_settings_timer = 15;
      gpus."10DE:2482-1458:408F-0000:2d:00.0" = {
        fan_control_enabled = false;
        power_cap = 250.0;
        min_core_clock = 210;
        max_core_clock = 2055;
        gpu_clock_offsets."0" = 40;
        mem_clock_offsets."0" = 1000;
      };
      current_profile = null;
      auto_switch_profiles = false;
    };
  };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
