{ ... }:

{
  wayland.windowManager.niri.settings.layout = {
    gaps = 16;
    center-focused-column = "never";

    preset-column-widths._children = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
    default-column-width.proportion = 0.5;

    preset-window-heights._children = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    focus-ring = {
      width = 2;
      active-color = "#7fc8ff";
      inactive-color = "#505050";
    };

    border.off = {};

    shadow = {
      on = {};
      spread = 10;
      softness = 15;
      offset._props = { x = 0; y = 0; };
    };
  };
}
