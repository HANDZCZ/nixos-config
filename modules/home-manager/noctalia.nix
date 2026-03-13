{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.programs.noctalia-shell;
  overlayType = lib.mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.programs.noctalia-shell = {
    basePackage = lib.mkOption {
      type = lib.types.package;
      default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "Base noctalia-shell package to which overlays will be applied.";
    };
    overlays = lib.mkOption {
      type = lib.types.listOf overlayType;
      default = [];
      description = ''
        List of overlays that override the package in some way
        and return the overriden package.
      '';
      example = lib.literalExpression ''
        [
          (final: prev: prev.override {
            extraPackages = [ pkgs.python3 ];
          })
        ]
      '';
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        List of addition packages that will be made available to noctalia.
      '';
      example = lib.literalExpression ''
        with pkgs; [
          bash
          gnused
        ]
      '';
    };
  };

  config.programs.noctalia-shell = let
    merged_overlays = lib.composeManyExtensions cfg.overlays;
    custom_package = lib.fix (lib.extends merged_overlays (_: cfg.basePackage));
    package = if cfg.overlays == [] then cfg.basePackage else custom_package;

    final_package = package.override (old-noct: {
      extraPackages = (old-noct.extraPackages or []) ++ cfg.extraPackages;
    });
  in {
    systemd.enable = lib.mkDefault true;
    package = lib.mkForce final_package;
    extraPackages = lib.optional (lib.attrByPath [ "appLauncher" "useApp2Unit" ] false cfg.settings) pkgs.app2unit;
  };
}
