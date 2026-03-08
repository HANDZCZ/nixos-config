{ inputs, pkgs, config, ... }:

let
  xdg = config.xdg;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./gitsigns.nix
    ./lualine.nix
    ./blink-cmp.nix
    ./startify.nix
    ./which-key.nix
    ./rnvimr.nix
    ./pandoc.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.onedark = {
      enable = true;
      settings = {
        style = "darker";
        # niri doesn't support blur yet
        #transparent = true;
      };
    };
    globals = {
      mapleader = " ";
    };
    opts = {
      # :h option-list
      number = true;
      relativenumber = true;

      # tab and indent related
      shiftwidth = 4;
      tabstop= 4;
      softtabstop = 4;
      expandtab = true;
      smartindent = true;

      # file history
      undofile = true;
      undodir="${xdg.stateHome}/vim/undodir";
      #noswapfile = true;
      updatetime = 5000;
      #nobackup = true;

      ruler = true;
      mouse = "a";
      #noerrorbells = true;
      incsearch = true;
      colorcolumn = [ 100 ];
      cmdheight = 1;
      shortmess = "ltToOCFc";
      spell = true;
      spelllang = [ "cs" "en" ];
    };
    plugins = {
      nix.enable = true;
    };
  };
}
