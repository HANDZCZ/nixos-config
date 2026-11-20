{ lib, pkgs, ... }:

{
  security.pki.certificateFiles = [
    ./Zscaler.crt
  ];
}
