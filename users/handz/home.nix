{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/prefer-dark.nix
    ./scripts
    ./noctalia.nix
    ./nixcord.nix
    ./git.nix
    ./bash.nix
    ./fonts.nix
  ];

  home.username = "handz";
  home.homeDirectory = "/home/handz";
  home.stateVersion = "25.11";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.commit.autoWrapCommitMessage = false;
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [];
  };

  home.packages = with pkgs; [
    btop
    htop
    brave
    eza
    bat
    yt-dlp
  ];
}
