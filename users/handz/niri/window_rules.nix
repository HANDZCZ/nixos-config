{ ... }:

{
  wayland.windowManager.niri.settings.window-rule = [
    {
      geometry-corner-radius = 8;
      clip-to-geometry = true;
    }
    {
      match._props.is-window-cast-target = true;

      focus-ring = {
        active-color = "#f38ba8";
        inactive-color = "#7d0d2d";
      };

      shadow = {
        on = {};
        color = "#7d0d2df0";
      };

      tab-indicator = {
        active-color = "#f38ba8";
        inactive-color = "#7d0d2d";
      };
    }

    # brave's PiP
    {
      match._props.title = "^Picture in picture$";
      open-focused = false;
      open-floating = true;
    }

    # fix steam notifications
    {
      match._props = {
        app-id = "steam";
        title._raw = ''r#"^notificationtoasts_\d+_desktop$"#'';
      };

      geometry-corner-radius = [ 8 0 0 0 ];
      shadow.off = {};

      open-focused = false;
      default-floating-position._props = { x = 0; y = 0; relative-to = "bottom-right"; };
      block-out-from = "screen-capture";
    }

    {
      match._props.app-id = "xdg-desktop-portal-gtk";

      default-column-width.fixed = 853;
      default-window-height.fixed = 470;
      open-floating = true;
    }

    {
      match._props.app-id = "^Alacritty$";
      background-effect.blur = true;
    }
  ];
}
