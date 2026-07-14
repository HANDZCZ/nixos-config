{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/handz
    ../../modules/pipewire-low-latency.nix
    ../../modules/zramSwap.nix
  ];

  kernel.ntsync.enable = true;
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

  # NOTE: TPM can't be enabled in bios or is not working and only slowing down boot
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  networking.networkmanager.enable = true;

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
