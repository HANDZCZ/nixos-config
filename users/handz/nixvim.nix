{ inputs, pkgs, config, ... }:

let
  xdg = config.xdg;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    extraPackages = with pkgs; [
      ranger
      ueberzugpp
    ];
    extraPython3Packages = p: with p; [
    ];

    defaultEditor = true;
    colorschemes.onedark = {
      enable = true;
      settings = {
        style = "darker";
      };
    };
    globals = {
      mapleader = " ";
      markdown_folding = 1;
      "pandoc#syntax#conceal#use" = 0;
      rnvimr_enable_ex = 1;
      rnvimr_hide_gitignore = 0;
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
    keymaps = [
      {
        action = "<cmd>RnvimrToggle<CR>";
        mode = "n";
        key = "<leader>r";
        options.desc = "Ranger";
      }
    ];
    extraPlugins = with pkgs.vimPlugins; [
      vim-pandoc
      vim-pandoc-syntax
      rnvimr
    ];
    plugins = {
      lualine = {
        enable = true;
        settings = {
          tabline = {
            lualine_a = [
              {
                __unkeyed-1 = "tabs";
                show_modified_status = false;
                use_mode_colors = true;
                max_length = { __raw = "vim.o.columns - 50"; };
                mode = 1;
                path = 0;
                fmt = { __raw = ''
                  function(name, context)
                    local buflist = vim.fn.tabpagebuflist(context.tabnr)
                    local winnr = vim.fn.tabpagewinnr(context.tabnr)
                    local bufnr = buflist[winnr]
                    local mod = vim.fn.getbufvar(bufnr, "&mod")

                    return name .. (mod == 1 and " +" or "")
                  end'';
                };
              }
            ];
            lualine_z = [
              {
                __unkeyed-1 = "datetime";
                style = "default";
              }
            ];
          };
        };
      };
      nix.enable = true;
      cmp =
      let
        next_item = ''
          function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end
        '';
        prev_item = ''
          function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end
        '';
      in{
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = ''
              function(fallback)
                if cmp.visible() then
                  if cmp.visible_docs() then
                    cmp.close_docs()
                  else
                    cmp.open_docs()
                  end
                else
                  fallback()
                end
              end
            '';
            "<CR>" = ''
              function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                  cmp.confirm()
                else
                  fallback()
                end
              end
            '';
            "<Down>" = "${next_item}";
            "<Tab>" = "${next_item}";
            "<Up>" = "${prev_item}";
            "<S-Tab>" = "${prev_item}";
            "<S-Down>" = ''
              function(fallback)
                if cmp.visible_docs() then
                  cmp.scroll_docs(4)
                else
                  fallback()
                end
              end
            '';
            "<S-Up>" = ''
              function(fallback)
                if cmp.visible_docs() then
                  cmp.scroll_docs(-4)
                else
                  fallback()
                end
              end
            '';
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            {
              name = "buffer";
              option = {
                get_bufnrs = {__raw = ''
                  function()
                    return vim.api.nvim_list_bufs()
                  end
                '';};
              };
            }
          ];
        };
      };
      startify = {
        enable = true;
        settings = {
          files_number = 10;
          fortune_use_unicode = true;
          session_autoload = true;
          session_delete_buffers = true;
          session_persistence = true;
          session_dir = "${xdg.stateHome}/vim/sessions/";
          enable_special = false;
          change_to_vcs_root = true;
          bookmarks = [
            {
              "n" = "~/.config/nixos";
            }
          ];
          lists =   [
            {
              type = "files";
              header = ["   Files"];
            }
            {
              type = "dir";
              header = [{__raw = "'   Current Directory' .. vim.loop.cwd()";}];
            }
            {
              type = "sessions";
              header = ["   Sessions"];
            }
            {
              type = "bookmarks";
              header = ["   Bookmarks"];
            }
          ];
        };
      };
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
