{ osConfig, pkgs, pkgs-unstable, user, lib, ... }:

{
  imports = [
    ../../modules/home-manager/prefer-dark.nix
    ../../modules/home-manager/polkit-gnome.nix
    ../../modules/home-manager/mailspring.nix
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
    ./ranger.nix
    ./obs.nix
  ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    BROWSER = "brave";
    NIXOS_OZONE_WL = "1";
  };

  programs.mailspring = {
    enable = true;
    # window doesn't get created under wayland
    # and no useful logs are produced...
    forceX11 = true;
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
    dua
    gnumake
    fd

    # browser
    brave

    # file browser
    nemo-with-extensions
    file-roller

    # media player
    mpv

    # music
    pkgs-unstable.pear-desktop

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
