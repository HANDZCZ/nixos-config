{ config, inputs, ... }:

{
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    lowLatency = {
      enable = true;
      quantum = 128;
      rate = 48000;
    };
    extraConfig = {
      pipewire."99-lowlatency" = {
        "context.properties"."default.clock.rate" = config.services.pipewire.lowLatency.rate;
        #"context.properties"."default.clock.allowed-rates" = [ 44100 48000 96000 ];
      };
    };
  };
  security.rtkit.enable = true;
}
