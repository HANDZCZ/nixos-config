{ hm-config, config, lib, pkgs, user-info, ... }:

let
  nixcord = hm-config.programs.nixcord;

  mkEntry = name: command:
    pkgs.makeDesktopItem {
      desktopName = "${name}-autostart";
      name = "${name}-autostart";
      # TODO: noctalia doesn't notify systemd when it's ready
      #       programs that expect tray to be available fail to start or start without it
      exec = "${pkgs.bash}/bin/bash -c \"sleep 3s; ${command}\"";
      destination = "/";
    } + "/${name}-autostart.desktop";
  mkCondEntry = condition: name: command: lib.mkIf condition (mkEntry name command);
  isInPackages = package:
    lib.any (p: lib.getName p == package) hm-config.home.packages
    || lib.any (p: lib.getName p == package) config.environment.systemPackages;
  mkInPkgsEntry = package: name: command: mkCondEntry (isInPackages package) name command;
in {
  home-manager.users.${user-info.name}.xdg.autostart = {
    enable = true;
    entries = [
      (mkCondEntry (nixcord.enable && nixcord.equibop.enable) "Equibop" "equibop --start-minimized")
      (mkInPkgsEntry "qbittorrent" "qBittorrent" "qbittorrent --confirm-legal-notice")
      (mkInPkgsEntry "signal-desktop" "Signal" "signal-desktop --start-in-tray")
      (mkCondEntry config.programs.steam.enable "Steam" "steam -nochatui -nofriendsui -silent")
      (mkInPkgsEntry "mailspring" "Mailspring" "mailspring --background")
    ];
  };
}
