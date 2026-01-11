{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/niri.nix
  ];

  users.users.handz = {
    isNormalUser = true;
    initialPassword = "secure_tm";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.handz = import ./home.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
    };
  };
  environment.sessionVariables = {
    XFT_DPI = "96";
  };
}
