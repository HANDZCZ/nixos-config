{ config, lib, pkgs, pkgs-unstable, ... }:

let
  nixcord = config.programs.nixcord;

  mkEntry = name: command:
    pkgs.makeDesktopItem {
      desktopName = "${name}-autostart";
      name = "${name}-autostart";
      exec = "${command}";
      destination = "/";
    } + "/${name}-autostart.desktop";
  mkCondEntry = condition: name: command: lib.mkIf condition (mkEntry name command);
  isInPackages = package: lib.elem pkgs.${package} config.home.packages || lib.elem pkgs-unstable.${package} config.home.packages;
  mkInPkgsEntry = package: name: command: mkCondEntry (isInPackages package) name command;
in {
  xdg.autostart = {
    enable = true;
    entries = [
      (mkCondEntry (nixcord.enable && nixcord.discord.enable) "Discord" "discord --start-minimized")
      (mkInPkgsEntry "qbittorrent" "qBittorrent" "qbittorrent --confirm-legal-notice")
      (mkInPkgsEntry "signal-desktop" "Signal" "signal-desktop --start-in-tray")
    ];
  };
}
