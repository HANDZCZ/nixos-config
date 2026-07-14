{ pkgs, config, user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        # no wayland support for now
        #input-overlay
        obs-dvd-screensaver
        obs-pipewire-audio-capture
        wlrobs
      ];
      package = pkgs.obs-studio.override {
        cudaSupport = config.hardware.nvidia.enabled;
      };
    };
  };
}
