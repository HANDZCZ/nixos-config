{ pkgs, inputs, ... }:

let
  user = "handz";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/niri.nix
    ../../modules/steam.nix
    ../../modules/wine-ntsync.nix
  ];

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "secure_tm";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
  };

  programs = {
    # needed to open ports
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ./home.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs user;
    };
  };
  environment.sessionVariables = {
    XFT_DPI = "96";
  };
}
