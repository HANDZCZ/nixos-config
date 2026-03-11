{ lib, ... }:

let
  git-keybind = "<leader>g";
in {
  programs.nixvim = {
    keymaps = [
      {
        action = "<cmd>Gitsigns preview_hunk_inline<CR>";
        mode = "n";
        key = "${git-keybind}i";
        options.desc = "Preview hunk inline";
      }
      {
        action = "<cmd>Gitsigns preview_hunk<CR>";
        mode = "n";
        key = "${git-keybind}p";
        options.desc = "Preview hunk";
      }
      {
        action = "<cmd>Gitsigns blame<CR>";
        mode = "n";
        key = "${git-keybind}B";
        options.desc = "Blame file";
      }
      {
        action = "<cmd>Gitsigns blame_line<CR>";
        mode = "n";
        key = "${git-keybind}L";
        options.desc = "Blame line";
      }
      {
        action = "<cmd>Gitsigns toggle_word_diff<CR>";
        mode = "n";
        key = "${git-keybind}w";
        options.desc = "Toggle word diff";
      }
      {
        action = "<cmd>Gitsigns diffthis origin/HEAD<CR>";
        mode = "n";
        key = "${git-keybind}d";
        options.desc = "Diff HEAD";
      }
    ];

    plugins = {
      which-key.settings.spec = [
        {
          __unkeyed = "${git-keybind}";
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
        };
      };
    };
  };
}

