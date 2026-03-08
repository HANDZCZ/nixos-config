{ pkgs, ... }:

{
  programs.nixvim = {
    globals = {
      markdown_folding = 1;
      "pandoc#syntax#conceal#use" = 0;
    };
    extraPlugins = with pkgs.vimPlugins; [
      vim-pandoc
      vim-pandoc-syntax
    ];
  };
}

