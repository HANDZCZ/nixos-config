{ config, ... }:

let
  xdg = config.xdg;
in {
  programs.nixvim = {
    plugins = {
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
    };
  };
}

