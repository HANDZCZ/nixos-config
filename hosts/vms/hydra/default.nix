{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/incus-virtual-machine.nix")
    ../../../modules/hydra.nix
    ../../../users/handz
  ];

  boot.loader.grub.enable = lib.mkForce false;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.hydra.port = 80;
  # Allow hydra to bind port 80
  systemd.services.hydra-server.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  };

  networking.firewall.allowedTCPPorts = [
    config.services.hydra.port
  ];

  nix.settings = {
    # use nix.optimise instead
    auto-optimise-store = lib.mkForce false;
  };

  nix.optimise = {
    automatic = true;
  };

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
