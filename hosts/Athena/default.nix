{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../users/handz
    ../../modules/zramSwap.nix
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  virtualisation.qemu.networkingOptions = lib.mkForce [
    "-device virtio-net-pci,netdev=net0"
    "-netdev bridge,id=net0,br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper"
  ];
  virtualisation = {
    memorySize = 8129;
    cores = 4;
  };

  system.stateVersion = "25.11";
}
