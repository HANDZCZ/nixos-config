# original stolen from: https://github.com/avrahamappel/nixfiles/commit/59e85e6b9c4ef0d4b09705c07ce33d83f1cffecd
{ config, pkgs, pkgs-unstable, lib, ... }:

let
  version = "1.17.3";
  hash = "sha256-cDnr8TxeVYH9ES1+l9JqgCoWO9IcXGZis+kNNVWHCmQ=";

  package = pkgs-unstable.mailspring.overrideAttrs (final: prev: {
    inherit version;
    useLibSecret = true;
    forceX11 = false;

    src = pkgs.fetchurl {
      url = prev.src.url;
      hash = hash;
    };

    nativeBuildInputs = with pkgs; prev.nativeBuildInputs ++ [
      patchelf
    ];

    runtimeDependencies = with pkgs; prev.runtimeDependencies ++ [
      curl
      libGL
      libnotify
      html-tidy
    ];

    postInstall =
      let
        flags = lib.optional final.useLibSecret "--password-store=gnome-libsecret"
          ++ lib.optional final.forceX11 "--enable-features=UseOzonePlatform --ozone-platform=x11";
      in (prev.postInstall or "") + lib.optionalString (lib.length flags != 0) ''
        wrapProgram $out/bin/mailspring --add-flags "${lib.concatStringsSep " " flags}"
      '';

    postFixup = prev.postFixup + ''
      patchelf --add-needed libEGL.so.1 $out/share/mailspring/libEGL.so
      patchelf --add-needed libGL.so.1 $out/share/mailspring/libGLESv2.so
    '';
  });

  upstream-package = pkgs-unstable.mailspring;
  assertions = [
    {
      assertion = !builtins.any (p: lib.getName p == "libnotify") upstream-package.runtimeDependencies;
      message = "`libnotify` has already been added to Mailspring's runtime dependencies";
    }
    {
      assertion = builtins.match "libEGL" upstream-package.postFixup == null;
      message = "https://github.com/NixOS/nixpkgs/pull/282748 has been merged, need to rework my fix";
    }
    {
      assertion = builtins.match "libGL" upstream-package.postFixup == null;
      message = "`libGL` has been added to postFixup";
    }
  ];
  cfg = config.programs.mailspring;
in {
  options.programs.mailspring = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Mailspring mail client.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "The Mailspring package to use.";
    };
    useLibSecret = lib.mkOption {
      type = lib.types.bool;
      default = cfg.package.useLibSecret;
      description = ''When enabled adds "--password-store=gnome-libsecret" to mailspring binary.'';
    };
    forceX11 = lib.mkOption {
      type = lib.types.bool;
      default = cfg.package.forceX11;
      description = "Whether to force the use of X11.";
    };
  };

  config = lib.mkIf cfg.enable {
    inherit assertions;
    home.packages = [
      (cfg.package.overrideAttrs {
        useLibSecret = cfg.useLibSecret;
        forceX11 = cfg.forceX11;
      })
    ];
  };
}

