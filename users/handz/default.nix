{ config, lib, pkgs, pkgs-unstable, host-info, ... }:

let
  user-info = {
    name = "handz";
  };

  hm-config = config.home-manager.users.${user-info.name};

  per-host-modules = rec {
    _shared = [
      ./bash.nix
      ./alacritty.nix
      ./starship.nix
      ./ssh.nix
      ./git.nix
      ./lazygit.nix
      ./scripts
      ./localsend.nix
      ./nixvim
      ./ranger.nix
      ./autostart.nix
      ./fonts.nix
      ./obs.nix
      ./xterm.nix
      ./browser.nix
    ];

    nixos-desktop = _shared ++ [
      ../../modules/sunshine.nix
      ./niri
      ./cursor_icon_themes.nix
      ./noctalia.nix
      ./xdg_portals.nix
      ./zerotierone.nix
      ./nemo.nix
      ./mailspring.nix
      ./nixcord.nix
      ./vscode.nix
      ./containerization.nix
      ./qimgv.nix
      ./distrobox.nix
      ./gaming.nix
      {
        home-manager.users.${user-info.name} = {
          imports = [
            ../../modules/home-manager/prefer-dark.nix
            ../../modules/home-manager/polkit-gnome.nix
          ];

          home.packages = with pkgs; [
            # Misc
            pkgs-unstable.signal-desktop
            qbittorrent
          ];
        };
      }
    ];
  };
in {
  imports = per-host-modules.${host-info.hostName};
  _module.args = { inherit user-info hm-config; };

  users.users.${user-info.name} = {
    isNormalUser = true;
    initialPassword = "secure_tm";
    extraGroups = [ "wheel" "networkmanager" "gamemode" ];
    packages = with pkgs; [];
  };

  home-manager.users.${user-info.name} = {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    xdg.mimeApps = {
      enable = true;
    };

    home.packages = with pkgs; [
      # misc
      mission-center
      yt-dlp

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
      nvd

      # media player
      mpv

      # music
      pkgs-unstable.pear-desktop

      # for testing graphics, steam, gamescope, ...
      vulkan-tools
    ]
    # htop for nvidia cards
    ++ lib.optionals config.hardware.nvidia.enabled [ pkgs.nvtopPackages.nvidia ];

    # WARN: use legacy home-manager setting so gtk4 apps get themed
    #       this also silences the warning
    gtk.gtk4.theme = lib.mkDefault hm-config.gtk.theme;

    home.username = "${user-info.name}";
    home.homeDirectory = "/home/${user-info.name}";
    home.stateVersion = "25.11";
  };
}
