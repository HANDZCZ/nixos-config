{ ... }:

{
  programs.nixvim = {
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
    };
  };
}

