{ lib, ... }:

{
  wayland.windowManager.niri = {
    settings = {
      # Allows notification actions and window activation from Noctalia.
      debug.honor-xdg-activation-with-invalid-serial = {};

      layer-rule = [
        # Don't show noctalia notifications in screen capture
        {
          match._props.namespace = "^noctalia-notifications-.*";
          block-out-from = "screen-capture";
        }

        # Set the overview wallpaper on the backdrop
        {
          match._props.namespace = "^noctalia-overview*";
          place-within-backdrop = true;
        }
      ];
    };
    # NOTE: this import needs to be at the end of niri config
    #       so it can override previously defined colors
    #       and the only way to ensure it is at the end is by using `extraConfig`
    extraConfig = lib.mkAfter /* kdl */ ''
      include optional=true "./noctalia.kdl"
    '';
  };
}
