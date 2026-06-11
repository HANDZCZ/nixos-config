{ ... }:

{
  wayland.windowManager.niri.settings.input = {
    keyboard.numlock = {};

    mouse = {
      accel-speed = 0.0;
      #accel-profile = "flat";
    };

    disable-power-key-handling = {};
    focus-follows-mouse._props.max-scroll-amount = "0%";
  };
}
