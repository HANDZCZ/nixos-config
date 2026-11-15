{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../users/handz
    ./VM.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "handz";
    ssh-agent.enable = false;
    useWindowsDriver = true;

  # Fixes warp not working
  networking.nftables.enable = true;
  systemd.services.cloudflare-warp = {
    serviceConfig = {
      BindReadOnlyPaths = [ "${lib.getExe pkgs.nftables}:/usr/sbin/nft" ];
    };
  };

  # Set back to default
  security.sudo.wheelNeedsPassword = true;

  # NOTE: Needed for Home Manager, otherwise you get a dbus error
  programs.dconf.enable = true;

  nix.settings = {
    trusted-users = [ "handz" ];
  };

  system.stateVersion = "25.11";
}
