{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      git.commit.autoWrapCommitMessage = false;
    };
  };
}
