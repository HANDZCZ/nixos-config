{ pkgs, ... }:

{
  programs.nixvim = {
    globals = {
      rnvimr_enable_ex = 1;
      rnvimr_hide_gitignore = 0;
    };
    extraPlugins = with pkgs.vimPlugins; [
      rnvimr
    ];
    extraPackages = with pkgs; [
      ranger
      ueberzugpp
    ];
    keymaps = [
      {
        action = "<cmd>RnvimrToggle<CR>";
        mode = "n";
        key = "<leader>r";
        options.desc = "Ranger";
      }
    ];
  };
}

