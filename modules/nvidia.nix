{ config, ... }:

{
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
}

