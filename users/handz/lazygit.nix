{ pkgs, user-info, ... }:

{
  home-manager.users.${user-info.name} = {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.lazygit = {
      enable = true;
      settings = {
        git.commit.autoWrapCommitMessage = false;
        gui.fileTreeSortOrder = "foldersFirst";
      };
    };
  };
}
