{ ... }:

let
  leader = "<leader>";
  history-keybind = "${leader}h";
  document-keybind = "${leader}d";
  git-keybind = "${leader}g";
  find-keybind = "${leader}f";
in {
  programs.nixvim = {
    keymaps = [
      # History
      {
        action = "<cmd>Telescope search_history<CR>";
        key = "${history-keybind}s";
        mode = "n";
        options.desc = "Search history";
      }
      {
        action = "<cmd>Telescope command_history<CR>";
        key = "${history-keybind}c";
        mode = "n";
        options.desc = "Command history";
      }

      # Document
      {
        action = "<cmd>Telescope treesitter<CR>";
        key = "${document-keybind}t";
        mode = "n";
        options.desc = "Treesitter functions, variables, ...";
      }
      {
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        key = "${document-keybind}s";
        mode = "n";
        options.desc = "LSP symbols";
      }

      # Git
      {
        action = "<cmd>Telescope git_status<CR>";
        key = "${git-keybind}s";
        mode = "n";
        options.desc = "Status";
      }
      {
        action = "<cmd>Telescope advanced_git_search diff_commit_file<CR>";
        key = "${git-keybind}b";
        mode = "n";
        options.desc = "File commits";
      }
      {
        action = "<cmd>Telescope advanced_git_search diff_commit_line<CR>";
        key = "${git-keybind}l";
        mode = "n";
        options.desc = "Line commits";
      }
      {
        action = "<cmd>Telescope advanced_git_search search_log_content_file<CR>";
        key = "${git-keybind}c";
        mode = "n";
        options.desc = "Search in file commits";
      }
      {
        action = "<cmd>Telescope advanced_git_search search_log_content<CR>";
        key = "${git-keybind}C";
        mode = "n";
        options.desc = "Search in repo commits";
      }

      # Find
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "${find-keybind}f";
        mode = "n";
        options.desc = "Files";
      }
      {
        action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
        key = "${find-keybind}b";
        mode = "n";
        options.desc = "In current buffer";
      }
      {
        action = "<cmd>Telescope buffers<CR>";
        key = "${find-keybind}o";
        mode = "n";
        options.desc = "Open buffers";
      }
      {
        action = "<cmd>Telescope grep_string<CR>";
        key = "${find-keybind}w";
        mode = "n";
        options.desc = "Word under cursor";
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "${find-keybind}g";
        mode = "n";
        options.desc = "Grep files";
      }

      # Misc
      {
        action = "<cmd>Telescope diagnostics<CR>";
        key = "${leader}D";
        mode = "n";
        options.desc = "Diagnostics";
      }
    ];

    dependencies = {
      ripgrep.enable = true;
      fd.enable = true;
    };

    plugins = {
      which-key.settings.spec = [
        {
          __unkeyed = "${history-keybind}";
          group = "History";
        }
        {
          __unkeyed = "${document-keybind}";
          group = "Document";
        }
        {
          __unkeyed = "${git-keybind}";
          group = "Git";
        }
        {
          __unkeyed = "${find-keybind}";
          group = "Find";
        }
      ];
      mini-icons = {
        enable = true;
        mockDevIcons = true;
      };
      telescope = {
        enable = true;
        extensions = {
          advanced-git-search.enable = true;
        };
      };
    };
  };
}
