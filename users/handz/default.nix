{ pkgs, inputs, pkgs-unstable, ... }:

let
  user = "handz";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/niri.nix
    ../../modules/steam.nix
    ../../modules/sunshine.nix
  ];

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "secure_tm";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [];
  };

  programs = {
    # needed to open ports
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
  };
  services.gvfs.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ./home.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs user pkgs-unstable;
    };
  };
}
