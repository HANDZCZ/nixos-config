{ osConfig, pkgs, pkgs-unstable, user, lib, ... }:

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
    ./vscode.nix
    ./containerization.nix
    ./lazygit.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    BROWSER = "brave";
    NIXOS_OZONE_WL = "1";
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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # no wayland support for now
      #input-overlay
      obs-dvd-screensaver
      obs-pipewire-audio-capture
      wlrobs
    ];
    package = pkgs.obs-studio.override {
      cudaSupport = osConfig.hardware.nvidia.enabled;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; lib.mkForce [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      };
    };
  };

  home.packages = with pkgs; [
    # misc
    pkgs-unstable.signal-desktop
    yt-dlp
    qbittorrent

    # development
    rustup
    gcc

    # basic utils
    btop
    htop
    fastfetch
    eza
    bat
    file
    ncdu
    gnumake

    # browser
    brave

    # file browser
    nemo-with-extensions
    file-roller

    # media player
    vlc

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
    # utils for winetricks
    unrar
    unzip
    cabextract
    p7zip
  ]
  # htop for nvidia cards
  ++ lib.optionals osConfig.hardware.nvidia.enabled [ pkgs.nvtopPackages.nvidia ];
}
