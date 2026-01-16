{ osConfig, pkgs, user, lib, ... }:

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

  home.sessionVariables = {
    #EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

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
    fastfetch
    brave
    eza
    bat
    yt-dlp
    qbittorrent
    gpu-screen-recorder
    nemo-with-extensions
    file-roller
    unrar
    unzip
    cabextract
    p7zip

    # for testing steam, gamescope, ...
    vulkan-tools

    # disk io tools
    sysstat # iostat
    iotop   # like ps for io
    iozone  # disk io speed testing

    # gaming
    lutris
    heroic
    protonplus
  ]
  # htop for nvidia cards
  ++ lib.optionals osConfig.hardware.nvidia.enabled [ pkgs.nvtopPackages.nvidia ];
}
