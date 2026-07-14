{ ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
    gfxmodeEfi = "1024x768";
    memtest86.enable = true;
    configurationLimit = 50;
  };
  boot.loader.efi.canTouchEfiVariables = true;
}

