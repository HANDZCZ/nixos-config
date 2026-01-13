{ pkgs, user, ... }:

{
  imports = [
    ../../modules/home-manager/prefer-dark.nix
    ../../modules/home-manager/polkit-gnome.nix
    ./scripts
    ./noctalia.nix
    ./nixcord.nix
    ./git.nix
    ./bash.nix
    ./fonts.nix
    ./cursor_icon_themes.nix
    ./alacritty.nix
    ./starship.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; lib.mkForce [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common.default = [ "gtk" "gnome" ];
    };
  };

  home.packages = with pkgs; [
    btop
    htop
    brave
    eza
    bat
    yt-dlp
    qbittorrent
    gpu-screen-recorder
  ];
}
