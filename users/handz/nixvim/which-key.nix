{ ... }:

{
  programs.nixvim = {
    plugins = {
      which-key = {
        enable = true;
        # https://github.com/bucccket/nixvim/blob/8164f473876db3fd1650c1437a9cbb264fe2acba/config/which-key.nix
        settings = {
          delay = 200;
          preset = "modern";
          icons = {
            breadcrumb = "»";
            group = "+";
            separator = "→";
            ellipsis = "…";
            colors = true;
            keys = {
              BS = "󰁮 ";
              C = "󰘴 ";
              CR = "󰌑 ";
              D = "󰘳 ";
              Down = " ";
              Esc = "󱊷 ";
              F1 = "󱊫";
              F2 = "󱊬";
              F3 = "󱊭";
              F4 = "󱊮";
              F5 = "󱊯";
              F6 = "󱊰";
              F7 = "󱊱";
              F8 = "󱊲";
              F9 = "󱊳";
              F10 = "󱊴 ";
              F11 = "󱊵 ";
              F12 = "󱊶 ";
              Left = " ";
              M = "󰘵 ";
              NL = "󰌑 ";
              Right = " ";
              S = "󰘶 ";
              ScrollWheelDown = "󱕐 ";
              ScrollWheelUp = "󱕑 ";
              Space = "󱁐 ";
              Tab = "󰌒 ";
              Up = " ";
            };
          };
          #win.border = "none";
        };
      };
    };
  };
}

