{ ... }:

{
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "kitty.desktop"
      ];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 5; y = 5; };
        opacity = 0.8;
      };
      keyboard = {
        bindings = [
          { key = "Numpad0"; chars = "0"; }
          { key = "Numpad1"; chars = "1"; }
          { key = "Numpad2"; chars = "2"; }
          { key = "Numpad3"; chars = "3"; }
          { key = "Numpad4"; chars = "4"; }
          { key = "Numpad5"; chars = "5"; }
          { key = "Numpad6"; chars = "6"; }
          { key = "Numpad7"; chars = "7"; }
          { key = "Numpad8"; chars = "8"; }
          { key = "Numpad9"; chars = "9"; }
        ];
      };
    };
  };
}
