{ osConfig, pkgs, user, lib, ... }:

{
  imports = [
    ../../modules/home-manager/prefer-dark.nix
    ../../modules/home-manager/polkit-gnome.nix
    ./scripts
    ./autostart.nix
    ./noctalia.nix
    ./nixcord.nix
    ./git.nix
    ./bash.nix
    ./fonts.nix
    ./cursor_icon_themes.nix
    ./alacritty.nix
    ./starship.nix
    ./nixvim.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    #EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  services.podman = {
    enable = true;
  };

  programs.ranger = {
    enable = true;
    settings = {
      show_hidden = true;
    };
    extraConfig = ''
      default_linemode devicons
    '';
    plugins = [
      {
        name = "ranger_devicons";
        src = builtins.fetchGit {
          url = "https://github.com/alexanderjeurissen/ranger_devicons.git";
          rev = "1bcaff0366a9d345313dc5af14002cfdcddabb82";
        };
      }
    ];
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
    ncdu
    podman-compose
    podman-desktop
    file
    gnumake

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
