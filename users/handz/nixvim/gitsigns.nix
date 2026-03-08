{ lib, ... }:

{
  programs.nixvim = {
    keymaps = [
      {
        action = "<cmd>Gitsigns preview_hunk_inline<CR>";
        mode = "n";
        key = "<leader>gi";
        options.desc = "Preview hunk inline";
      }
      {
        action = "<cmd>Gitsigns preview_hunk<CR>";
        mode = "n";
        key = "<leader>gp";
        options.desc = "Preview hunk";
      }
      {
        action = "<cmd>Gitsigns blame<CR>";
        mode = "n";
        key = "<leader>gb";
        options.desc = "Blame file";
      }
      {
        action = "<cmd>Gitsigns blame_line<CR>";
        mode = "n";
        key = "<leader>gl";
        options.desc = "Blame line";
      }
      {
        action = "<cmd>Gitsigns toggle_word_diff<CR>";
        mode = "n";
        key = "<leader>gw";
        options.desc = "Toggle word diff";
      }
      {
        action = "<cmd>Gitsigns diffthis origin/HEAD<CR>";
        mode = "n";
        key = "<leader>gd";
        options.desc = "Diff HEAD";
      }
    ];

    plugins = {
      which-key.settings.spec = [
        {
          __unkeyed = "<leader>g";
          group = "Git";
        }
      ];
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 200;
          };
          numhl = true;
          signs = lib.genAttrs [
            "add"
            "change"
            "changedelete"
            "delete"
            "topdelete"
          ] (_: { show_count = true; });
          preview_config = {
            border = "rounded";
          };
        };
        luaConfig.post = ''
          vim.api.nvim_set_hl(0, "GitSignsAddInline", { bg = "#284828" })
          vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = "#1f2f45" })
          vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = "#4a2424" })
        '';
      };
    };
  };
}

