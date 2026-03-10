{ config, lib, ... }:

let
  blink-cmp-cfg = config.programs.nixvim.plugins.blink-cmp;
  blink-cmp-providers = blink-cmp-cfg.settings.sources.providers;
in {
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
          sources = {
            default = [ "lsp" "buffer" "snippets" "path" ]
              ++ lib.optional blink-cmp-providers.spell.enabled "spell";
            providers = {
              spell = {
                enabled = true;
                module = "blink-cmp-spell";
                name = "Spell";
                score_offset = -100;
                opts = {
                  max_entries = 25;
                };
              };
            };
          };
        };
      };
      blink-cmp-spell.enable = blink-cmp-providers.spell.enabled;
    };
  };
}

