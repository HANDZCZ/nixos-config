{ lib, ... }:

{
  virtualisation.vmVariant = {
    wsl.enable = lib.mkForce false;
  };
}
