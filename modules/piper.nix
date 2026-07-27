{ pkgs, ... }:

let
  libratbag = pkgs.libratbag.overrideAttrs (prev: {
    src = pkgs.fetchFromGitHub {
      inherit (prev.src) owner repo;
      rev = "03afbe49f30a4fd18d830530685804eb3bd57c39";
      sha256 = "sha256-vlo3RfpLJQTw7P5Bmopl8vi4nDrY9OwNM6tVja+scq8=";
    };
  });
in {
  services.ratbagd = {
    enable = true;
    package = libratbag;
  };

  environment.systemPackages = with pkgs; [
    piper
  ];
}
