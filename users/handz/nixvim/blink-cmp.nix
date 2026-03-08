{ ... }:

{
  programs.nixvim = {
    plugins = {
      colorful-menu.enable = true;
      blink-cmp = {
        enable = true;
        settings = {
          signature.enabled = true;
          keymap = {
            preset = "enter";
            highlight.enable = true;
          };
          completion.menu.draw = {
            columns = [ { __unkeyed = "kind_icon"; } { __unkeyed = "label"; gap = 1; } ];
            components.label = {
              text.__raw = ''
                function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end
              '';
              highlight.__raw = ''
                function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end
              '';
            };
          };
          completion.list = {
            max_items = 2000;
            selection = {
              preselect = false;
              auto_insert = false;
            };
          };
        };
      };
    };
  };
}

