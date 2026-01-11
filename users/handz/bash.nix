{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      # NixOS
      nix-rbs = "sudo nixos-rebuild switch --flake ~/.config/nixos#nixos-desktop";
    };
  };
}
