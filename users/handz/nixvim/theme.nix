{ config, pkgs-unstable, lib, ... }:

{
  warnings = let
    cfg = config.programs.nixvim;
    treesitter-plugin = cfg.plugins.treesitter;
  in lib.optional (!treesitter-plugin.enable) "Nixvim: theme One Dark Pro needs treesitter enabled to function properly."
    ++ lib.optional (treesitter-plugin.enable && treesitter-plugin.settings.highlight.enable == null) ''
      Nixvim: theme One Dark Pro needs treesitter to function properly.
      Consider setting `treesitter.settings.highlight.enable` to true,
      to automaticaly enable treesitter for supported file types.
    '';

  programs.nixvim = {
    colorscheme = "onedark";
    extraPlugins = [
      # use unstable package, because it fixes some color definitions for plugins
      pkgs-unstable.vimPlugins.onedarkpro-nvim
    ];

    extraConfigLua = ''
      vim.o.winborder = 'single'
    '';
    extraConfigLuaPre = let
      helpers = "require('onedarkpro.helpers')";
      git_add_color = "green";
      git_change_color = "blue";
      git_delete_color = "red";
    in /* lua */ ''
      require("onedarkpro").setup({
        colors = {
          onedark = { bg = "#23272e" },

          git_add = "${helpers}.darken('${git_add_color}', 10)",
          git_change = "${helpers}.darken('${git_change_color}', 10)",
          git_delete = "${helpers}.darken('${git_delete_color}', 10)",

          highlight_add = "${helpers}.darken('${git_add_color}', 30)",
          highlight_change = "${helpers}.darken('${git_change_color}', 30)",
          highlight_delete = "${helpers}.darken('${git_delete_color}', 30)",

          diff_add = "${helpers}.darken('${git_add_color}', 50)",
          diff_change = "${helpers}.darken('${git_change_color}', 50)",
          diff_delete = "${helpers}.darken('${git_delete_color}', 50)",
        },
        highlights = {
          SpellBad = {
            sp = "''${red}",
            undercurl = true,
          },
          SpellCap = {
            sp = "''${yellow}",
            undercurl = true,
          },
          SpellLocal = {
            sp = "''${blue}",
            undercurl = true,
          },
          SpellRare = {
            sp = "''${green}",
            undercurl = true,
          },
          GitSignsAddInline = { bg = "''${highlight_add}" },
          GitSignsChangeInline = { bg = "''${highlight_change}" },
          GitSignsDeleteInline = { bg = "''${highlight_delete}" },
          -- fix fg color being overridden, making TODO, ERROR, INFO, WARN text unreadable
          [ "@lsp.type.comment.nix" ] = { },
        },
        plugins = {
          startify = false,
        },
      })
    '';
  };
}

